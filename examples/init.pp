###
# For all types the name must match exactly the name from
# the secpol gui
###

user_rights_assignment { 'Perform volume maintenance tasks':
  security_setting => ['BUILTIN\Administrators'],
}
user_rights_assignment { 'Lock pages in memory':
  security_setting => ['CRUCIBLE0\dev'],
}

# security_setting can be set to 
# no_auditing
# success
# failure
# success_failure
event_audit { 'Audit logon events':
  security_setting => 'failure',
}

system_access { 'Account lockout duration':
  security_setting => '30',
}