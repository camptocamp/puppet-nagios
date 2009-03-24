#
# modules/nagios/manifests/definitions/service-remote.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::host::distributed ($ensure=present, $address="", $nagios_alias, $hostgroups, $contact_groups) {
  
  $addr = $address ? {
    "" => $ipaddress,
    default => $address,
  }

  nagios_host {$name:
    ensure  => $ensure,
    use     => "generic-host-active",
    address => $addr,
    alias   => $nagios_alias,
    target  => "$nagios_cfg_dir/hosts.cfg",
    notify  => Exec["nagios-reload"],
    require => File["$nagios_cfg_dir/hosts.cfg"],
  }

  @@nagios_host {"@@$name":
    ensure => $ensure,
    use => "generic-host-passive",
    address => $addr,
    host_name => $name,
    alias => $nagios_alias,
    tag => "nagios",
    hostgroups => $hostgroups,
    contact_groups => $contact_groups,
    target => "$nagios_cfg_dir/hosts.cfg",
    notify => Exec["nagios-reload"],
    require => File["$nagios_cfg_dir/hosts.cfg"],
  }
}
