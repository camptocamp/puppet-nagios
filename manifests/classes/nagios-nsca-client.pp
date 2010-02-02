#
# modules/nagios/manifests/nsca-client.pp
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

class nagios::nsca::client {

  if defined (Package["nsca"]) {
    notice "Package nsca is already defined"
  } else {
    package {"nsca":
      ensure => installed;
    }
  }
  
  case $operatingsystem {

    RedHat,Fedora,CentOS: {
      if defined (Package["nsca-client"]) {
        notice "Package nsca-client is already defined"
      } else {
        package { "nsca-client": ensure => installed }
      }
    }
    default: {}
  }

  file {"/etc/send_nsca.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("nagios/send_nsca.cfg.erb"),
    require => Package["nsca"],
    notify  => Service["nagios"],
  }

  file {"/usr/local/bin/submit_ocsp":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 755,
    content => template("nagios/submit_ocsp.erb"),
    require => File["/etc/send_nsca.cfg"],
  }

  file {"/usr/local/bin/submit_ochp":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 755,
    content => template("nagios/submit_ochp.erb"),
    require => File["/etc/send_nsca.cfg"],
  }

  nagios_command {"submit_ocsp":
    ensure        => present,
    command_line  => "/usr/local/bin/submit_ocsp \$HOSTNAME\$ '\$SERVICEDESC\$' \$SERVICESTATEID\$ '\$SERVICEOUTPUT\$'",
    target        => "$nagios_cfg_dir/commands.cfg",
    notify        => Exec["nagios-reload"],
    require       => File["/etc/send_nsca.cfg"],
  }

  nagios_command {"submit_ochp":
    ensure        => present,
    command_line  => "/usr/local/bin/submit_ochp \$HOSTNAME\$ \$HOSTSTATE\$ '\$HOSTOUTPUT\$'",
    target        => "$nagios_cfg_dir/commands.cfg",
    notify        => Exec["nagios-reload"],
    require       => File["/etc/send_nsca.cfg"],
  }

  common::concatfilepart {"submit_ocsp":
    file    => $nagios_main_config_file,
    content => "ocsp_command=submit_ocsp\n",
    notify  => Exec["nagios-reload"],
  }

  common::concatfilepart {"submit_ochp":
    file    => $nagios_main_config_file,
    content => "ochp_command=submit_ochp\n",
    notify  => Exec["nagios-reload"],
  }

}
