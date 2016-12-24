require 'spec_helper'

describe Secpol::IniManager do
  describe :read_ini_file do
    specify 'errors if the file does not exist' do
      path = 'C:/not there/not a file.ini'
      expect { Secpol::IniManager.read_ini_file path }.to raise_error "#{path} does not exist"
    end
  end
end
