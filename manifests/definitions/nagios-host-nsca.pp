#
# modules/nagios/manifests/definitions/nagios-host-nsca.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::host::nsca ($ensure=present, $export_for, $address=false, $nagios_alias=false, $hostgroups=false, $contact_groups=false) {

  nagios_host {$name:
    ensure  => $ensure,
    use     => "generic-host-active",
    address => $address ? {false => $ipaddress, default => $address},
    alias   => $nagios_alias ? {false => undef, default => $nagios_alias},
    target  => "$nagios_cfg_dir/hosts.cfg",
    notify  => Exec["nagios-reload"],
    require => File["$nagios_cfg_dir/hosts.cfg"],
  }

  @@nagios_host {"@@$name":
    ensure     => $ensure,
    use        => "generic-host-passive",
    address    => $address ? {false => $ipaddress, default => $address},
    host_name  => $name,
    alias      => $nagios_alias ? {false => undef, default => $nagios_alias},
    tag        => "nagios-${export_for}",
    hostgroups => $hostgroups ? {false => undef, default => $hostgroups},
    target     => "$nagios_cfg_dir/hosts.cfg",
    notify     => Exec["nagios-reload"],
    require    => File["$nagios_cfg_dir/hosts.cfg"],
    contact_groups => $contact_groups ? {false => undef, default => $contact_groups},
  }
}