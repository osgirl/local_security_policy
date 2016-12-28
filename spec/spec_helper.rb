require 'puppetlabs_spec_helper/module_spec_helper'
require 'puppet_x/user_rights_assignment/lookup'

def fixtures_path
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  fixtures_path = File.join(proj_root, 'spec', 'fixtures')
end

RSpec.configure do |c|
  c.formatter = 'documentation'
  c.mock_with :rspec
end
