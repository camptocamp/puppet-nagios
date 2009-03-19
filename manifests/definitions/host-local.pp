#
# modules/nagios/manifests/definitions/host-local.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::host::local ($ensure=present, $address="", $alias=undef, hostgroups=undef) {

  $addr = $address ? {
    "" => $ipaddress,
    default => $address,
  }

  nagios_host {$name:
    ensure => $ensure,
    use => "generic-host-active",
    address => $addr,
    alias => $alias,
    hostgroups => $hostgroups,
    target => "$nagios_cfg_dir/hosts.cfg",
    notify => Exec["nagios-reload"],
    require => File["$nagios_cfg_dir/hosts.cfg"],
  }

}
