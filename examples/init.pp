user_rights_assignment { 'Perform volume maintenance tasks':
  security_setting => ['BUILTIN\Administrators'],
}
user_rights_assignment { 'Lock pages in memory':
  security_setting => ['CRUCIBLE0\dev'],
}