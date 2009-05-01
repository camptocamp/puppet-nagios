#
# modules/nagios/manifests/definitions/service-distributed.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::distributed ($ensure=present, $service_description, $host_name=false, $contact_groups=false) {

  nagios_service {$name:
    ensure => $ensure,
    use => "generic-service-active",
    host_name => $host_name ? {false => $hostname, default => $host_name},
    check_command => $name,
    tag => "nagios",
    service_description => $service_description,
    target => "$nagios_cfg_dir/services.cfg",
    require => File["$nagios_cfg_dir/services.cfg"],
    notify => Exec["nagios-reload"],
  }

  @@nagios_service {"@@$name on $hostname":
    ensure => $ensure,
    use => "generic-service-passive",
    host_name => $host_name ? {false => $hostname, default => $host_name},
    tag => "nagios",
    service_description => $service_description,
    target => "$nagios_cfg_dir/services.cfg",
    require => File["$nagios_cfg_dir/services.cfg"],
    notify => Exec["nagios-reload"],
    contact_groups => $contact_groups ? {false => undef, default => $contact_groups},
  }

}
