#
# modules/nagios/manifests/nsca-client.pp
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

class nagios::nsca::client {

  include nagios::params

  if !defined (Package["nsca"]) {
    package {"nsca":
      ensure => installed;
    }
  }

  if $operatingsystem =~ /RedHat|Fedora|CentOS/ {
    if !defined (Package["nsca-client"]) {
      package { "nsca-client": ensure => installed }
    }
  }

  # variables used in ERB template
  $nsca_server = $nagios_nsca_server
  $nsca_cfg = "${nagios::params::rootdir}/send_nsca.cfg"

  file { "${nagios::params::rootdir}/send_nsca.cfg":
    ensure  => present,
    owner   => root,
    group   => nagios,
    mode    => 640,
    content => template("nagios/send_nsca.cfg.erb"),
    require => [Package["nsca"], Package["nagios"]],
    notify  => Service["nagios"],
  }

  file {"/usr/local/bin/submit_ocsp":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 755,
    content => template("nagios/submit_ocsp.erb"),
    require => File["${nagios::params::rootdir}/send_nsca.cfg"],
  }

  file {"/usr/local/bin/submit_ochp":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 755,
    content => template("nagios/submit_ochp.erb"),
    require => File["${nagios::params::rootdir}/send_nsca.cfg"],
  }

  file { "${nagios::params::resourcedir}/command-submit_ocsp.cfg":
    ensure => present,
    owner  => "root",
    mode   => 0644,
  }

  nagios_command {"submit_ocsp":
    ensure        => present,
    command_line  => "/usr/local/bin/submit_ocsp \$HOSTNAME\$ '\$SERVICEDESC\$' \$SERVICESTATEID\$ '\$SERVICEOUTPUT\$'",
    target        => "${nagios::params::resourcedir}/command-submit_ocsp.cfg",
    notify        => Exec["nagios-restart"],
    require       => File["${nagios::params::resourcedir}/command-submit_ocsp.cfg"],
  }

  file { "${nagios::params::resourcedir}/command-submit_ochp.cfg":
    ensure => present,
    owner  => "root",
    mode   => 0644,
  }

  nagios_command {"submit_ochp":
    ensure        => present,
    command_line  => "/usr/local/bin/submit_ochp \$HOSTNAME\$ \$HOSTSTATE\$ '\$HOSTOUTPUT\$'",
    target        => "${nagios::params::resourcedir}/command-submit_ochp.cfg",
    notify        => Exec["nagios-restart"],
    require       => File["${nagios::params::resourcedir}/command-submit_ochp.cfg"],
  }

  common::concatfilepart {"submit_ocsp":
    file    => "${nagios::params::conffile}",
    content => "ocsp_command=submit_ocsp\n",
    notify  => Exec["nagios-restart"],
  }

  common::concatfilepart {"submit_ochp":
    file    => "${nagios::params::conffile}",
    content => "ochp_command=submit_ochp\n",
    notify  => Exec["nagios-restart"],
  }

  #TODO: remove this resource in a while
  file { "/etc/send_nsca.cfg": ensure => absent }

}
