#
# modules/nagios/manifests/definitions/service-remote.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::remote ($ensure=present, $service_description="", $host_name="") {
  
  $desc = $service_description ? {
    "" => $name,
    default => $service_description,
  }

  $tmp_host_name = $host_name ? {
    "" => $hostname,
    default => $host_name,
  }

  @@nagios_service {"@@$name on $tmp_host_name":                
    ensure                => $ensure,
    use                   => "generic-service-passive",
    host_name             => $tmp_host_name,
    tag                   => "nagios",
    service_description   => $desc,
    target                => "$nagios_cfg_dir/services.cfg",
    require               => File["$nagios_cfg_dir/services.cfg"],
    notify                => Exec["nagios-reload"],
  }
}
