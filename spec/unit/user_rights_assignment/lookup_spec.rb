require 'spec_helper'

describe :friendly_name do
  specify 'returns unknown if the system name is not found' do
    expect(UserRightsAssignment::Lookup.friendly_name('blah')).to eq('Unknown setting: blah')
  end
  specify 'returns the friendly name if the system name is found' do
    expect(UserRightsAssignment::Lookup.friendly_name('SeDebugPrivilege')).to eq('Debug programs')
  end
end

describe :system_name do
  specify 'errors if the friendly name is not found' do
    expect{ UserRightsAssignment::Lookup.system_name('blah') }.to raise_error('Unknown friendly name: blah')
  end
  specify 'returns the system name if the friendly name is found' do
    expect(UserRightsAssignment::Lookup.system_name('Deny log on locally')).to eq('SeDenyInteractiveLogonRight')
  end
end
