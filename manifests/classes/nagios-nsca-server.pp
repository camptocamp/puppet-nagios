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
    enable      => true,
    hasrestart  => true,
    hasstatus   => false,
    pattern     => "/usr/sbin/nsca",
    require     => Package["nsca"],
  }

  Nagios_host <<| tag == "nagios-${fqdn}" |>>
  Nagios_service <<| tag == "nagios-${fqdn}" |>>
  Nagios_command <<| tag == "nagios-${fqdn}" |>>

  case $operatingsystem {
    Debian: { $nagios_nsca_cfg = "/etc/nsca.cfg" }
    default: { $nagios_nsca_cfg = "${nagios_root_dir}/nsca.cfg" }
  }

  file {"${nagios_nsca_cfg}":
    ensure  => present,
    owner   => root,
    group   => nagios,
    mode    => 640,
    content => template("nagios/nsca.cfg.erb"),
    require => [Package["nsca"], Package["nagios"], Class["nagios::base"]],
    notify  => Service["nsca"],
  }

}
