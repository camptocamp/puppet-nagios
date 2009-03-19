#
# modules/nagios/manifests/definitions/service-remote.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::host::distributed ($ensure=present, $address="", $alias=undef, $hostgroups=undef) {
  
  $addr = $address ? {
    "" => $ipaddress,
    default => $address,
  }

  nagios_host {$name:
    ensure  => $ensure,
    use     => "generic-host-active",
    address => $addr,
    alias   => $alias,
    target  => "$nagios_cfg_dir/hosts.cfg",
    notify  => Exec["nagios-reload"],
    require => File["$nagios_cfg_dir/hosts.cfg"],
  }

  @@nagios_host {"@@$name":
    ensure      => $ensure,
    use         => "generic-host-passive",
    address     => $addr,
    host_name   => $name,
    hostgroups  => $hostgroups,
    alias     => $alias,
    tag       => "nagios",
    target    => "$nagios_cfg_dir/hosts.cfg",
    notify    => Exec["nagios-reload"],
    require   => File["$nagios_cfg_dir/hosts.cfg"],
  }

}
