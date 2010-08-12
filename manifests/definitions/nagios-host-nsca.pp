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

  nagios_host {$name:
    ensure  => $ensure,
    use     => "generic-host-active",
    address => $address ? {
      false => $ipaddress,
      default => $address,
    },
    alias   => $nagios_alias,
    target  => "${nagios_cfg_dir}/hosts.cfg",
    notify  => Exec["nagios-reload"],
    require => [
      Class["nagios::base"],
      File["nagios_hosts.cfg"],
    ],
  }

  @@nagios_host {"@@$name":
    ensure     => $ensure,
    use        => "generic-host-passive",
    address    => $address ? {
      false => $ipaddress,
      default => $address,
    },
    host_name  => $name,
    alias      => $nagios_alias,
    tag        => $export_for,
    hostgroups => $hostgroups,
    target     => "${nagios_cfg_dir}/hosts.cfg",
    contact_groups => $contact_groups,
    notify     => Exec["nagios-reload"],
    require => [
      Class["nagios::base"],
      File["nagios_hosts.cfg"],
    ],
  }
}
