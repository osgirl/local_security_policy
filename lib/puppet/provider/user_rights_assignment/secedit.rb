require_relative '../../../puppet_x/user_rights_assignment/lookup'

Puppet::Type.type(:user_rights_assignment).provide(:secedit) do
  confine operatingsystem: :windows

  commands secedit: 'secedit',
           powershell:
              if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
              elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
              else
                'powershell.exe'
              end
  mk_resource_methods

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def self.instances
    inf = read_policy_settings
    settings = process_lines inf
    convert_sids @sids
    settings.each.collect do |setting|
      new(system_to_friendly(setting))
    end
  end

  def security_setting=(value)
    write_file
    secedit(['/configure', '/db', 'C:\\db.sdb', '/cfg', 'C:\\Windows\\Temp\\write.ini', '/quiet'])
  end

  def write_file
    text = <<-TEXT
[Version]
signature="$CHICAGO$"
Revision=1
[Unicode]
Unicode=yes
[Privilege Rights]
    TEXT
    setting_name = UserRightsAssignment::Lookup.system_name @resource[:policy]
    sids = convert_users @resource[:security_setting]
    setting_line = "#{setting_name} = #{sids}"
    text += setting_line
    out_file = File.new('C:\\Windows\\Temp\\write.ini', 'w')
    out_file.puts(text)
    out_file.close
  end

  def convert_users(users)
    users = self.class.replace_incorrect_users users
    input = self.class.join_array users
    command = <<-COMMAND
#{input} | % {
$objUser = New-Object System.Security.Principal.NTAccount($_)
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value
}
    COMMAND
    output = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    starred = output.lines.each.collect do |line|
      "*#{line.strip}"
    end
    starred.join(',')
  end

  # fix for Win10/Server2016
  def self.replace_incorrect_users(users)
    index = users.index('BUILTIN\\System Managed Group')
    if index
      users[index] = 'BUILTIN\\System Managed Accounts Group'
    end
    users
  end

  def self.convert_line(line)
    @sids ||= []
    name = line.split('=')[0].strip
    setting = line.split('=')[1].strip.delete('*').split(',')
    @sids.concat setting
    {
      name: name,
      security_setting: setting
    }
  end

  def self.process_lines(inf)
    settings = []
    current_section = ''
    inf.each_line do |line|
      if line.strip =~ /\[(.*?)\]/
        current_section = line.strip
        next
      end
      next if current_section !~ /\[Privilege Rights\]/
      settings << convert_line(line)
    end
    settings
  end

  def self.convert_sids(sids)
    sids.delete('Guest')
    input = join_array sids
    command = <<-COMMAND
#{input} | % {
$objSID = New-Object System.Security.Principal.SecurityIdentifier($_)
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
"$($_):$($objUser.Value)"
}
    COMMAND
    output = powershell(['-noprofile', '-executionpolicy', 'bypass', '-command', command])
    UserRightsAssignment::Lookup.sid_mapping = convert_ps_output_to_hash output
  end

  def self.system_to_friendly(setting)
    users = setting[:security_setting].each.collect do |sid|
      if sid != 'Guest'
        UserRightsAssignment::Lookup.user_name(sid)
      else
        sid
      end
    end
    {
      name: UserRightsAssignment::Lookup.friendly_name(setting[:name]),
      security_setting: users
    }
  end

  def self.convert_ps_output_to_hash(output)
    result = {}
    output.lines.each do |line|
      sid = line.split(':')[0].strip
      result[sid] = line.split(':')[1].strip
    end
    result
  end

  def self.join_array(array)
    quoted = array.each.collect do |member|
      "\"#{member}\""
    end
    quoted.join(',')
  end

  def self.export_policy_settings(inffile = nil)
    inffile ||= temp_file
    secedit(['/export', '/cfg', inffile, '/quiet'])
    inffile
  end

  def self.read_policy_settings(inffile = nil)
    inffile ||= temp_file
    unless @file_object
      export_policy_settings(inffile)
      File.open inffile, 'r:IBM437' do |file|
        # remove /r/n and remove the BOM
        @file_object = file.read.force_encoding('utf-16le').encode(
          'utf-8', universal_newline: true
        ).delete("\xEF\xBB\xBF")
      end
    end
    @file_object
  end

  def self.temp_file
    'c:\\secedit.inf'
  end
end
