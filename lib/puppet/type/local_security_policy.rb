require_relative '../../puppet_x/lsp/security_policy'

Puppet::Type.newtype(:local_security_policy) do
  @doc = 'Puppet type that models the local security policy'

  newparam(:name) do
    desc 'Local Security Setting Name. What you see in the GUI.'
    validate do |value|
      raise ArgumentError, "Invalid Policy name: #{value}" unless SecurityPolicy.valid_lsp?(value)
    end
  end

  newproperty(:policy_value) do
    desc 'Local Security Policy Setting Value'
    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError('Value cannot be nil or empty')
      end
    end
  end
end
