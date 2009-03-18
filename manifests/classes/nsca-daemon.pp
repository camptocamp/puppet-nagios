#
# modules/nagios/manifests/classes/nsca-daemon.pp
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

class nagios::nsca::daemon {

  if defined (Package["nsca"]) {
    notice "Package nsca is already defined"
  } else {
    package {"nsca":
      ensure => installed;
    }
  }

  # nsca package only post-configure stop, not start
  exec {"install nsca init script":
    command => "update-rc.d -f nsca remove && update-rc.d nsca defaults 99 16",
    unless  => "test -f /etc/rc2.d/S99nsca",
    require => Package["nsca"],
  }

  service {"nsca":
    ensure      => running,
    hasrestart  => true,
    require     => Package["nsca"],
  }

  file {"/etc/nsca.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("nagios/nsca.cfg.erb"),
    require => Package["nsca"],
    notify  => Service["nsca"],
  }

  Nagios_host <<| tag == "nagios" |>>
  Nagios_service <<| tag == "nagios" |>>

}
