require 'spec_helper'

provider_class = Puppet::Type.type(:user_rights_assignment).provider(:secedit)
describe provider_class do
  describe :convert_line do
  end
  describe :convert_sids do
  end
  describe :join_array do
    specify 'converts array to quoted comma separated string' do
      input = ['item1', 'item2', 'item3']
      output = provider_class.join_array input
      expect(output).to eq '"item1","item2","item3"'
    end
  end
end
