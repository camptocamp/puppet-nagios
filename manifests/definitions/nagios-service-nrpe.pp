#
# modules/nagios/manifests/definitions/nagios-local-service.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::nrpe ($ensure=present, $export_for="", $service_description=false, $host_name=false, $contact_groups=false, $normal_check_interval=false, $retry_check_interval=false) {

  nagios_service {$name:
    ensure                => $ensure,
    use                   => "generic-service-active",
    host_name             => $host_name ? {false => $hostname, default => $host_name},
    check_command         => $name,
    tag                   => $export_for ? {
                               ""      => "nagios-nrpe-${fqdn}",
                               default => $export_for,
                             },
    service_description   => $service_description ? {false => undef, default => $service_description},
    contact_groups        => $contact_groups ? {false => undef, default => $contact_groups},
    normal_check_interval => $normal_check_interval ? {false => undef, default => $normal_check_interval},
    retry_check_interval  => $retry_check_interval ? {false => undef, default => $retry_check_interval},
    target                => "$nagios_cfg_dir/services.cfg",
    require               => File["nagios_services.cfg"],
    notify                => Exec["nagios-reload"],
  }

  @@nagios_service {"@@$name on $hostname":
    ensure                => $ensure,
    use                   => "generic-service-active",
    host_name             => $host_name ? {false => $hostname, default => $host_name},
    check_command         => "nrpe_${name}",
    tag                   => $export_for ? {
                               ""      => "nagios-nrpe-${fqdn}",
                               default => $export_for,
                             },
    service_description   => $service_description ? {false => undef, default => $service_description},
    contact_groups        => $contact_groups ? {false => undef, default => $contact_groups},
    normal_check_interval => $normal_check_interval ? {false => undef, default => $normal_check_interval},
    retry_check_interval  => $retry_check_interval ? {false => undef, default => $retry_check_interval},
    target                => $nagios_master_cfg_config? { true => "$nagios_master_cfg_config_value/services.cfg", default => "$nagios_cfg_dir/services.cfg"},
    notify                => Exec["nagios-reload"],
  }
}
