class nagios::plugins {

  package {"liblwp-useragent-determined-perl":
    ensure => present,
  }

  file {"/usr/lib/nagios/plugins/check_apachestatus":
    ensure => present,
    source  => "puppet:///nagios/plugins/check_apachestatus",
    owner => root,
    group => root,
    mode => 755,
    require => [Package["liblwp-useragent-determined-perl"], Package["nagios-plugins"]],
  }

  file {"/usr/lib/nagios/plugins/check_asterisk":
    ensure => present,
    source  => "puppet:///nagios/plugins/check_asterisk",
    owner => root,
    group => root,
    mode => 755,
  }
  
}

