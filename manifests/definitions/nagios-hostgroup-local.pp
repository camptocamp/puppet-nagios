#
# modules/nagios/manifests/definitions/host-local.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::local::hostgroup ($ensure=present) {

  include nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  nagios_hostgroup { $name:
    ensure  => $ensure,
    target  => "${nagios::params::resourcedir}/hostgroup-${fname}.cfg",
    notify  => Exec["nagios-restart"],
  }

  file { "${nagios::params::resourcedir}/hostgroup-${fname}.cfg":
    ensure => $ensure,
    owner  => "root",
    mode   => 0644,
    before => Nagios_hostgroup[$name],
  }

}
