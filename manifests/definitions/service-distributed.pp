#
# modules/nagios/manifests/definitions/service-distributed.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::distributed ($ensure=present, $service_description="", $host_name="", contact_groups) {

  $desc = $service_description ? {
    "" => $name,
    default => $service_description,
  }

  $tmp_hostname = $host_name ? {
    ""  => $hostname,
    default => $host_name,
  } 

  nagios_service {$name:
    ensure                => $ensure,
    use                   => "generic-service-active",
    host_name             => $tmp_hostname,
    check_command         => $name,
    tag                   => "nagios",
    service_description   => $desc,
    target                => "$nagios_cfg_dir/services.cfg",
    require               => File["$nagios_cfg_dir/services.cfg"],
    notify                => Exec["nagios-reload"],
  }

  @@nagios_service {"@@$name on $hostname":
    ensure                => $ensure,
    use                   => "generic-service-passive",
    host_name             => $tmp_hostname,
    tag                   => "nagios",
    service_description   => $desc,
    target                => "$nagios_cfg_dir/services.cfg",
    require               => File["$nagios_cfg_dir/services.cfg"],
    notify                => Exec["nagios-reload"],
    contact_groups        => $contact_groups,
  }

}
