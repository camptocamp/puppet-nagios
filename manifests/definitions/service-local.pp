#
# modules/nagios/manifests/definitions/service-local.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::local ($ensure=present, $service_description="") {
    
  $desc = $service_description ? {
    ""      => $name,
    default => $service_description,
  }

  nagios_service {$name:
    ensure                => $ensure,
    use                   => "generic-service-active",
    host_name             => $hostname,
    check_command         => $name,
    tag                   => "nagios",
    service_description   => $desc,
    target                => "$nagios_cfg_dir/services.cfg",
    require               => File["$nagios_cfg_dir/services.cfg"],
    notify                => Exec["nagios-reload"],
  }

}
