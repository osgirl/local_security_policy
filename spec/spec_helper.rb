require 'puppetlabs_spec_helper/module_spec_helper'
require 'puppet_x/secpol/inimanager'
require 'puppet_x/secpol/inifile'
require 'puppet_x/secpol/inisection'

def fixtures_path
    proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    fixtures_path = File.join(proj_root, 'spec', 'fixtures')
end

RSpec.configure do |c|
  c.formatter = 'documentation'
  c.mock_with :rspec
end
