require_relative '../../../puppet_x/system_access/lookup'
require_relative '../secedit'

Puppet::Type.type(:system_access).provide(:secedit, parent: Puppet::Provider::Secedit) do
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
    settings.each.collect do |setting|
      new(setting)
    end
  end

  def security_setting=(value)
    write_file
    secedit(['/configure', '/db', 'C:\\Windows\\Temp\\db.sdb', '/cfg', 'C:\\Windows\\Temp\\write.ini', '/quiet'])
    FileUtils.rm_f 'C:\\Windows\\Temp\\write.ini'
    FileUtils.rm_f 'C:\\Windows\\Temp\\db.sdb'
    FileUtils.rm_f 'C:\\Windows\\Temp\\db.jfm'
  end

  def write_file
    text = <<-TEXT
[Version]
signature="$CHICAGO$"
Revision=1
[Unicode]
Unicode=yes
[System Access]
    TEXT
    setting_name = SystemAccess::Lookup.system_name @resource[:policy]
    setting_value = @resource[:security_setting]
    setting_line = "#{setting_name} = #{setting_value}"
    text += setting_line
    out_file = File.new('C:\\Windows\\Temp\\write.ini', 'w')
    out_file.puts(text)
    out_file.close
  end

  def self.convert_line(line)
    name = line.split('=')[0].strip
    setting_value = line.split('=')[1].strip.delete('"')
    {
      name: SystemAccess::Lookup.friendly_name(name),
      security_setting: setting_value
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
      settings << convert_line(line) if current_section == '[System Access]'
    end
    settings
  end
end
