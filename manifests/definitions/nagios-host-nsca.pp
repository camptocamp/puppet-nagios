#
# modules/nagios/manifests/definitions/nagios-host-nsca.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::host::nsca (
  $ensure=present,
  $export_for,
  $address=false,
  $nagios_alias=undef,
  $hostgroups=undef,
  $contact_groups=undef
  ) {

  include nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  nagios_host { $name:
    ensure  => $ensure,
    use     => "generic-host-active",
    address => $address ? {
      false   => $ipaddress,
      default => $address,
    },
    alias   => $nagios_alias,
    target  => "${nagios::params::resourcedir}/host-${fname}.cfg",
    notify  => Exec["nagios-reload"],
    require => Class["nagios::base"],
  }

  file { "${nagios::params::resourcedir}/host-${fname}.cfg":
    ensure => $ensure,
  }

  @@nagios_host { "@@$name":
    ensure     => $ensure,
    use        => "generic-host-passive",
    address    => $address ? {
      false   => $ipaddress,
      default => $address,
    },
    host_name  => $name,
    alias      => $nagios_alias,
    tag        => $export_for,
    hostgroups => $hostgroups,
    target     => "${nagios::params::resourcedir}/collected-host-${fname}.cfg",
    contact_groups => $contact_groups,
    notify     => Exec["nagios-reload"],
    require    => Class["nagios::base"],
  }

  @@file { "${nagios::params::resourcedir}/collected-host-${fname}.cfg":
    ensure => $ensure,
    tag    => $export_for,
  }

}
