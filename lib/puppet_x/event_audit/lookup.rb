module EventAudit
  class Lookup

    def self.friendly_name(system_name)
      return "Unknown setting: #{system_name}" unless @mapping.invert[system_name]
      @mapping.invert[system_name]
    end

    def self.system_name(friendly_name)
      raise "Unknown friendly name: #{friendly_name}" unless @mapping[friendly_name]
      @mapping[friendly_name]
    end

    def self.friendly_to_system_mapping
      @mapping
    end

    def self.system_to_friendly_mapping
      @mapping.invert
    end

    def self.int_to_setting_mapping
      @setting_mapping
    end

    def self.setting_to_int_mapping
      @setting_mapping.invert
    end

    @mapping = {
      'Audit account logon events' => 'AuditAccountLogon',
      'Audit account management' => 'AuditAccountManage',
      'Audit directory service access' => 'AuditDSAccess',
      'Audit logon events' => 'AuditLogonEvents',
      'Audit object access' => 'AuditObjectAccess',
      'Audit policy change' => 'AuditPolicyChange',
      'Audit privilege use' => 'AuditPrivilegeUse',
      'Audit process tracking' => 'AuditProcessTracking',
      'Audit system events' => 'AuditSystemEvents'
    }

    @setting_mapping = {
      '0' => :no_auditing,
      '1' => :success,
      '2' => :failure,
      '3' => :success_failure
    }
  end
end
