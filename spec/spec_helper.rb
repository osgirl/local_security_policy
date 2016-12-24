require 'puppetlabs_spec_helper/module_spec_helper'
require 'puppet_x/secpol/inimanager'
require 'puppet_x/secpol/inifile'

RSpec.configure do |c|
  c.formatter = 'documentation'
  c.mock_with :rspec
end
