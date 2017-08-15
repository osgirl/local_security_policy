require_relative '../../../puppet_x/event_audit/lookup'
require_relative '../secedit'

Puppet::Type.type(:event_audit).provide(:secedit, parent: Puppet::Provider::Secedit) do
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
    file_name = DateTime.now.strftime('%Y%m%dT%H%M.log')
    secedit([
      '/configure', '/db', 'C:\\Windows\\Temp\\db.sdb',
      '/cfg', 'C:\\Windows\\Temp\\write.ini',
      '/log', "C:\\Windows\\security\\logs\\#{file_name}"
    ])
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
[Event Audit]
    TEXT
    setting_name = EventAudit::Lookup.system_name @resource[:policy]
    setting_value = EventAudit::Lookup.setting_to_int_mapping[@resource[:security_setting]]
    setting_line = "#{setting_name} = #{setting_value}"
    text += setting_line
    out_file = File.new('C:\\Windows\\Temp\\write.ini', 'w')
    out_file.puts(text)
    out_file.close
  end

  def self.convert_line(line)
    name = line.split('=')[0].strip
    settingint = line.split('=')[1].strip
    {
      name: EventAudit::Lookup.friendly_name(name),
      security_setting: EventAudit::Lookup.int_to_setting_mapping[settingint]
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
      settings << convert_line(line) if current_section == '[Event Audit]'
    end
    settings
  end
end
