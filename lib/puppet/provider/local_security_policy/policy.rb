require 'fileutils'
require_relative '../../../puppet_x/secpol/inimanager'
require_relative '../../../puppet_x/secpol/inifile'
require_relative '../../../puppet_x/secpol/inisection'

Puppet::Type.type(:local_security_policy).provide(:policy) do
  desc 'Puppet type that models the local security policy'
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

  def initialize(value = {})
    super(value)
    @property_flush = {}
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
        ).gsub("\xEF\xBB\xBF", '')
      end
    end
    @file_object
  end

  def self.instances
    settings = []
    inf = read_policy_settings
    current_section = ''
    inf.each_line do |line|
      if line.strip =~ /\[(.*?)\]/
        current_section = line.strip
        next
      end
      next if current_section =~ /\[Unicode\]/ || current_section =~ /\[Version\]/
      settings << new(
        name: line.split('=')[0].strip,
        policy_value: line.split('=')[1].strip
      )
    end
    settings
  end

  # required for easier mocking, this could be a Tempfile too
  def self.temp_file
    'c:\\secedit.inf'
  end

  def temp_file
    'c:\\secedit.inf'
  end
end
