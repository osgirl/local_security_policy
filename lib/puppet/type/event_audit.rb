Puppet::Type.newtype(:event_audit) do

  newparam(:policy, namevar: true) do
    validate do |value|
      raise ArgumentError, "Invalid Policy name: #{value}" unless EventAudit::Lookup.system_name(value)
    end
  end

  newproperty(:security_setting) do
    newvalues(:no_auditing, :success, :failure, :success_failure)
  end
end
