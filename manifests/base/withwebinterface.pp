class nagios::base::withwebinterface inherits nagios::base {
  case $::osfamily {
    'Debian': {
      $group = 'www-data'
    }
    'RedHat': {
      $group = 'apache'
    }
    default: {
      fail "Unsupported osfamily: ${::osfamily}"
    }
  }
  File['nagios read-write dir'] {
    group => $group,
  }
}
