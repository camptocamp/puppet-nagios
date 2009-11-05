#
# modules/nagios/manifests/definitions/nagios-nsca-service.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::nsca ($ensure=present,
                              $service_description=false, 
                              $export_for,
                              $host_name=false,
                              $contact_groups=false, 
                              $use_active="generic-service-active", 
                              $use_passive="generic-service-passive",
                              $package=false
                              ) {

  nagios_service {$name:
    ensure => $ensure,
    use => $use_active,
    host_name => $host_name ? {false => $hostname, default => $host_name},
    check_command => $name,
    tag => "nagios-${export_for}",
    service_description => $service_description,
    target => "$nagios_cfg_dir/services.cfg",
    require => File["nagios_services.cfg"],
    notify => Exec["nagios-reload"],
  }

  @@nagios_service {"@@$name on $hostname":
    ensure => $ensure,
    use => $use_passive,
    host_name => $host_name ? {false => $hostname, default => $host_name},
    tag => "nagios-${export_for}",
    service_description => $service_description,
    target     => $nagios_master_cfg_config? { true => "$nagios_master_cfg_config_value/services.cfg", default => "$nagios_cfg_dir/services.cfg"},
    notify => Exec["nagios-reload"],
    contact_groups => $contact_groups ? {false => undef, default => $contact_groups},
  }

  if $package {
    if defined( Package["$package"] ) {
      notice "$package already defined"
    } else {
      package {$package:
        ensure => present,
      }
    }
  }
}
