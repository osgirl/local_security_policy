module SystemAccess
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

    @mapping = {
      'Enforce password history' => 'PasswordHistorySize',
      'Maximum password age' => 'MaximumPasswordAge',
      'Minimum password age' => 'MinimumPasswordAge',
      'Minimum password length' => 'MinimumPasswordLength',
      'Password must meet complexity requirements' => 'PasswordComplexity',
      'Store passwords using reversible encryption' => 'ClearTextPassword',
      'Account lockout duration' => 'LockoutDuration',
      'Account lockout threshold' => 'LockoutBadCount',
      'Reset account lockout counter after' => 'ResetLockoutCount',
      'Accounts: Administrator account status' => 'EnableAdminAccount',
      'Accounts: Guest account status' => 'EnableGuestAccount',
      'Network security: Force logoff when logon hours expire' => 'ForceLogoffWhenHourExpire',
      'Accounts: Rename administrator account' => 'NewAdministratorName',
      'Accounts: Rename guest account' => 'NewGuestName',
      'Network access: Allow anonymous SID/Name translation' => 'LSAAnonymousNameLookup',
      'RequireLogonToChangePassword' => 'RequireLogonToChangePassword' #This setting is ignored
    }
  end
end
