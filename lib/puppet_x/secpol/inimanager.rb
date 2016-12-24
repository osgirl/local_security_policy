module Secpol
  class IniManager
    def self.read_ini_file(path)
      raise "#{path} does not exist" unless File.exist? path
    end
  end
end
