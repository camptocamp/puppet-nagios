#
# modules/nagios/manifests/classes/nsca-server.pp
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

class nagios::nsca::server {

  if defined (Package["nsca"]) {
    notice "Package nsca is already defined"
  } else {
    package {"nsca":
      ensure => installed;
    }
  }

  service {"nsca":
    ensure      => running,
    hasrestart  => true,
    require     => Package["nsca"],
  }

  Nagios_host <<| tag == "nagios-${fqdn}" |>>
  Nagios_service <<| tag == "nagios-${fqdn}" |>>

  
  case $operatingsystem {
    Debian: {
      # nsca package only post-configure stop, not start
      exec {"install nsca init script":
        command => "update-rc.d -f nsca remove && update-rc.d nsca defaults 99 16",
        unless  => "test -f /etc/rc2.d/S99nsca",
        require => Package["nsca"],
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
    }
    RedHat: {
      exec {"install nsca init script":
        command => "chkconfig nsca on",
        unless  => "chkconfig --list | egrep -q 'nsca.*on'",
        require => Package["nsca"],
      }

      file {"/etc/nagios/nsca.cfg":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        content => template("nagios/nsca.cfg.erb"),
        require => Package["nsca"],
        notify  => Service["nsca"],
      }

    }
    default: { err ("operatingsystem $operatingsystem not yet implemented !") }
  }
}
