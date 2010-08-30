#
# modules/nagios/manifests/definitions/nagios-host.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::host (
  $ensure=present,
  $address=false,
  $nagios_alias=undef,
  $hostgroups=undef,
  $contact_groups=undef
  ) {

  include nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  nagios_host { $name:
    ensure     => $ensure,
    use        => "generic-host-active",
    address    => $address ? {
      false   => $ipaddress,
      default => $address,
    },
    alias      => $nagios_alias,
    hostgroups => $hostgroups,
    contact_groups => $contact_groups,
    target     => "${nagios::params::resourcedir}/host-${fname}.cfg",
    notify     => Exec["nagios-reload"],
  }

  file { "${nagios::params::resourcedir}/host-${fname}.cfg":
    ensure => $ensure,
    before => Nagios_host[$name],
  }

}
