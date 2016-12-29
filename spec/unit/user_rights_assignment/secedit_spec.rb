require 'spec_helper'

provider_class = Puppet::Type.type(:user_rights_assignment).provider(:secedit)
describe provider_class do
  before(:all) do
    allow_any_instance_of(FileUtils).to receive(:rm_f).and_return(nil)
  end
  describe :convert_line do
    specify 'returns a hash of the setting name and associated SIDs' do
      input = 'SeChangeNotifyPrivilege = *S-1-1-0,*S-1-5-19,*S-1-5-20,*S-1-5-32-544,*S-1-5-32-545,*S-1-5-32-551'
      output = provider_class.convert_line input
      expected = {
        name: 'SeChangeNotifyPrivilege',
        security_setting: ['S-1-1-0','S-1-5-19','S-1-5-20','S-1-5-32-544','S-1-5-32-545','S-1-5-32-551']
      }
      expect(output).to eq(expected)
    end
  end
  describe :convert_ps_output_to_hash do
    specify 'converts colon separated list of strings to hash' do
      input = <<-INPUT
S-1-5-32-544:BUILTIN\\Administrators
S-1-5-32-545:BUILTIN\\Users
S-1-5-32-551:BUILTIN\\Backup Operators
S-1-5-32-581:BUILTIN\\System Managed Group
      INPUT
      output = provider_class.convert_ps_output_to_hash input
      expected = {
        'S-1-5-32-544' => 'BUILTIN\\Administrators',
        'S-1-5-32-545' => 'BUILTIN\\Users',
        'S-1-5-32-551' => 'BUILTIN\\Backup Operators',
        'S-1-5-32-581' => 'BUILTIN\\System Managed Group'
      }
      expect(output).to eq(expected)
    end
  end
  describe :join_array do
    specify 'converts array to quoted comma separated string' do
      input = ['item1', 'item2', 'item3']
      output = provider_class.join_array input
      expect(output).to eq '"item1","item2","item3"'
    end
  end
  describe :replace_incorrect_users do
    specify 'replaces incorrect array value with the correct value' do
      input = ['BUILTIN\\Administrators', 'CRUCIBLE0\\Service Accounts', 'BUILTIN\\System Managed Group']
      output = provider_class.replace_incorrect_users input
      expected = ['BUILTIN\\Administrators', 'CRUCIBLE0\\Service Accounts', 'BUILTIN\\System Managed Accounts Group']
      expect(output).to eq(expected)
    end
    specify 'only alters incorrect array value' do
      input = ['BUILTIN\\Administrators', 'CRUCIBLE0\\Service Accounts', 'NT AUTHORITY\\SERVICE']
      output = provider_class.replace_incorrect_users input
      expect(output).to eq(input)
    end
  end
  describe :process_lines do
    specify 'returns array of setting names and associated SIDs from an ini file' do
      allow(provider_class).to receive(:export_policy_settings).and_return(nil)
      inf = provider_class.read_policy_settings(File.join(fixtures_path, 'unit', 'short_secedit.inf'))
      output = provider_class.process_lines inf
      expected_file = File.join(fixtures_path, 'unit', 'process_lines_expected.json')
      expected = JSON.parse(File.read(expected_file), symbolize_names: true)
      expect(output).to match_array(expected)
    end
  end
end
