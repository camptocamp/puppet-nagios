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


  nagios_command {"submit_ocsp":
    ensure        => present,
    command_line  => "/usr/local/bin/submit_ocsp \$HOSTNAME\$ '\$SERVICEDESC\$' \$SERVICESTATEID\$ '\$SERVICEOUTPUT\$'",
    target        => "$nagios_cfg_dir/commands.cfg",
    notify        => Exec["nagios-reload"],
    require       => Class["nagios::base"],
  }

  nagios_command {"submit_ochp":
    ensure        => present,
    command_line  => "/usr/local/bin/submit_ochp \$HOSTNAME\$ \$HOSTSTATE\$ '\$HOSTOUTPUT\$'",
    target        => "$nagios_cfg_dir/commands.cfg",
    notify        => Exec["nagios-reload"],
    require       => Class["nagios::base"],
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
