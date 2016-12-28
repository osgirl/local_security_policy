Puppet::Type.newtype(:user_rights_assignment) do

  newparam(:policy, namevar: true) do
    validate do |value|
      raise ArgumentError, "Invalid Policy name: #{value}" unless UserRightsAssignment::Lookup.system_name(value)
    end
  end

  newproperty(:security_setting, array_matching: :all) do
    def insync?(is)
      is.sort == should.sort
    end
  end
end
