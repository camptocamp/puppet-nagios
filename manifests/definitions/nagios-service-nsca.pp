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
                              $normal_check_interval=false,
                              $retry_check_interval=false,
                              $use_active="generic-service-active", 
                              $use_passive="generic-service-passive",
                              $package=false
                              ) {

  nagios::service::local {$name:
    ensure      => $ensure,
    use         => $use_active,
    export_for  => $export_for,
    host_name   => $host_name ? {false => $hostname, default => $host_name},
    contact_groups      => $contact_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    service_description   => $service_description,
  }

  @@nagios_service {"@@$name on $hostname":
    ensure    => $ensure,
    use       => $use_passive,
    host_name => $host_name ? {false => $hostname, default => $host_name},
    tag       => $export_for,
    target    => $nagios_master_cfg_config? { true => "$nagios_master_cfg_config_value/services.cfg", default => "$nagios_cfg_dir/services.cfg"},
    notify    => Exec["nagios-reload"],
    contact_groups        => $contact_groups ? {false => undef, default => $contact_groups},
    normal_check_interval => $normal_check_interval ? {false => undef, default => $normal_check_interval},
    retry_check_interval  => $retry_check_interval ? {false => undef, default => $retry_check_interval},
    service_description   => $service_description,
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
