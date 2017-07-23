Puppet::Type.newtype(:system_access) do

  newparam(:policy, namevar: true) do
    validate do |value|
      raise ArgumentError, "Invalid Policy name: #{value}" unless SystemAccess::Lookup.system_name(value)
    end
  end

  newproperty(:security_setting) do
  end
end
