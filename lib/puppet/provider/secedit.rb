class Puppet::Provider::Secedit < Puppet::Provider
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
    FileUtils.rm_f inffile
    @file_object
  end

  def self.temp_file
    'C:\\Windows\\Temp\\secedit.inf'
  end
end
