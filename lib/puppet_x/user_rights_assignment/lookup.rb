module UserRightsAssignment
  class Lookup
    def self.sid_mapping=(value)
      @sid_mapping = value
    end

    def self.sid_mapping
      @sid_mapping
    end

    def self.friendly_name(system_name)
      return "Unknown setting: #{system_name}" unless @mapping.invert[system_name]
      @mapping.invert[system_name]
    end

    def self.system_name(friendly_name)
      raise "Unknown friendly name: #{friendly_name}" unless @mapping[friendly_name]
      @mapping[friendly_name]
    end

    def self.sid(user_name)
      return "Unknown user name: #{user_name}" unless @sid_mapping.invert[user_name]
      @sid_mapping.invert[user_name]
    end

    def self.user_name(sid)
      raise "Unknown SID: #{sid}" unless @sid_mapping[sid]
      @sid_mapping[sid]
    end

    @mapping = {
      'Access Credential Manager as a trusted caller' => 'SeTrustedCredManAccessPrivilege',
      'Access this computer from the network' => 'SeNetworkLogonRight',
      'Act as part of the operating system' => 'SeTcbPrivilege',
      'Add workstations to domain' => 'SeMachineAccountPrivilege',
      'Adjust memory quotas for a process' => 'SeIncreaseQuotaPrivilege',
      'Allow log on locally' => 'SeInteractiveLogonRight',
      'Allow log on through Remote Desktop Services' => 'SeRemoteInteractiveLogonRight',
      'Back up files and directories' => 'SeBackupPrivilege',
      'Bypass traverse checking' => 'SeChangeNotifyPrivilege',
      'Change the system time' => 'SeSystemtimePrivilege',
      'Change the time zone' => 'SeTimeZonePrivilege',
      'Create a pagefile' => 'SeCreatePagefilePrivilege',
      'Create a token object' => 'SeCreateTokenPrivilege',
      'Create global objects' => 'SeCreateGlobalPrivilege',
      'Create permanent shared objects' => 'SeCreatePermanentPrivilege',
      'Create symbolic links' => 'SeCreateSymbolicLinkPrivilege',
      'Debug programs' => 'SeDebugPrivilege',
      'Deny access to this computer from the network' => 'SeDenyNetworkLogonRight',
      'Deny log on as a batch job' => 'SeDenyBatchLogonRight',
      'Deny log on as a service' => 'SeDenyServiceLogonRight',
      'Deny log on locally' => 'SeDenyInteractiveLogonRight',
      'Deny log on through Remote Desktop Services' => 'SeDenyRemoteInteractiveLogonRight',
      'Enable computer and user accounts to be trusted for delegation' => 'SeEnableDelegationPrivilege',
      'Force shutdown from a remote system' => 'SeRemoteShutdownPrivilege',
      'Generate security audits' => 'SeAuditPrivilege',
      'Impersonate a client after authentication' => 'SeImpersonatePrivilege',
      'Increase a process working set' => 'SeIncreaseWorkingSetPrivilege',
      'Increase scheduling priority' => 'SeIncreaseBasePriorityPrivilege',
      'Load and unload device drivers' => 'SeLoadDriverPrivilege',
      'Lock pages in memory' => 'SeLockMemoryPrivilege',
      'Log on as a batch job' => 'SeBatchLogonRight',
      'Log on as a service' => 'SeServiceLogonRight',
      'Manage auditing and security log' => 'SeSecurityPrivilege',
      'Modify an object label' => 'SeRelabelPrivilege',
      'Modify firmware environment values' => 'SeSystemEnvironmentPrivilege',
      'Perform volume maintenance tasks' => 'SeManageVolumePrivilege',
      'Profile single process' => 'SeProfileSingleProcessPrivilege',
      'Profile system performance' => 'SeSystemProfilePrivilege',
      'Remove computer from docking station' => 'SeUndockPrivilege',
      'Replace a process level token' => 'SeAssignPrimaryTokenPrivilege',
      'Restore files and directories' => 'SeRestorePrivilege',
      'Shut down the system' => 'SeShutdownPrivilege',
      'Synchronize directory service data' => 'SeSyncAgentPrivilege',
      'Take ownership of files or other objects' => 'SeTakeOwnershipPrivilege'
    }
  end
end
