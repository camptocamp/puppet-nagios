#
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::host::remote (
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
    require => [
      Class["nagios::base"],
      File["nagios_hosts.cfg"],
    ],
  }

  file { "${nagios::params::resourcedir}/host-${fname}.cfg":
    ensure => $ensure,
  }


  @@nagios_host { "@@${name}":
    ensure     => $ensure,
    use        => "generic-host-active",
    tag        => $export_for,
    host_name  => $name,
    address    => $address ? {
      false   => $ipaddress,
      default => $address,
    },
    alias      => $nagios_alias,
    hostgroups => $hostgroups,
    contact_groups => $contact_groups,
    target     => "${nagios::params::resourcedir}/host-${fname}.cfg",
    notify     => Exec["nagios-reload"],
    require    => [
      Class["nagios::base"],
      File["nagios_hosts.cfg"],
    ],
  }

  @@file { "${nagios::params::resourcedir}/host-${fname}.cfg":
    ensure => $ensure,
    tag    => $export_for,
  }

}
