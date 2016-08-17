class nagios::base::withwebinterface inherits nagios::base {
  case $::osfamily {
    'Debian': {
      $group  = 'www-data'
      $rw_dir = '/var/lib/nagios3/rw'
    }
    'RedHat': {
      $group  = 'apache'
      $rw_dir = '/var/spool/nagios/cmd'
    }
    default: {
      fail "Unsupported osfamily: ${::osfamily}"
    }
  }
  file { $rw_dir:
    ensure  => directory,
    group   => $group,
    require => Package['nagios'],
  }
}
