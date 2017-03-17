require 'spec_helper'

provider_class = Puppet::Type.type(:user_rights_assignment).provider(:secedit)
describe provider_class do
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
  describe :system_to_friendly do
    specify 'converts hash of setting names and SIDS to friendly name and user names' do
      allow(Puppet::Util::Windows::SID).to receive(:valid_sid?).and_return(true)
      allow(Puppet::Util::Windows::SID).to receive(:sid_to_name).with('S-1-5-32-544').and_return('BUILTIN\\Administrators')
      allow(Puppet::Util::Windows::SID).to receive(:sid_to_name).with('S-1-5-32-545').and_return('BUILTIN\\Users')
      allow(Puppet::Util::Windows::SID).to receive(:sid_to_name).with('S-1-5-32-551').and_return('BUILTIN\\Backup Operators')
      input = {
        name: 'SeNetworkLogonRight',
        security_setting: ['S-1-5-32-544', 'S-1-5-32-545', 'S-1-5-32-551']
      }
      output = provider_class.system_to_friendly input
      expected = {
        name: 'Access this computer from the network',
        security_setting: ['BUILTIN\\Administrators', 'BUILTIN\\Users', 'BUILTIN\\Backup Operators']
      }
      expect(output).to eq(expected)
    end
    specify 'does not lookup the SID value if it is not a SID' do
      allow(Puppet::Util::Windows::SID).to receive(:valid_sid?).with('Guest').and_return(false)
      allow(Puppet::Util::Windows::SID).to receive(:valid_sid?).with('SQLServer2005SQLBrowserUser$PUPPET-SQLTEST6').and_return(false)
      allow(Puppet::Util::Windows::SID).to receive(:valid_sid?).with('S-1-5-32-551').and_return(true)
      allow(Puppet::Util::Windows::SID).to receive(:sid_to_name).with('S-1-5-32-551').and_return('BUILTIN\\Backup Operators')
      input = {
        name: 'SeNetworkLogonRight',
        security_setting: ['Guest', 'SQLServer2005SQLBrowserUser$PUPPET-SQLTEST6', 'S-1-5-32-551']
      }
      output = provider_class.system_to_friendly input
      expected = {
        name: 'Access this computer from the network',
        security_setting: ['Guest', 'SQLServer2005SQLBrowserUser$PUPPET-SQLTEST6', 'BUILTIN\\Backup Operators']
      }
      expect(output).to eq(expected)
    end
  end
  describe :add_unset_policies do
    specify 'adds any settings from the lookup not in the input with an empty user array' do
      allow(UserRightsAssignment::Lookup).to receive(:friendly_to_system_mapping).and_return(
        'Right1' => 'Value1', 'Right2' => 'Value2', 'Right3' => 'Value3'
      )
      input_file = File.join(fixtures_path, 'unit', 'process_lines_expected.json')
      input = JSON.parse(File.read(input_file), symbolize_names: true)
      expected = input
      expected << { name: 'Right1', security_setting: [] }
      expected << { name: 'Right2', security_setting: [] }
      expected << { name: 'Right3', security_setting: [] }
      output = provider_class.add_unset_policies input
      expect(output).to eq(expected)
    end
  end
end
