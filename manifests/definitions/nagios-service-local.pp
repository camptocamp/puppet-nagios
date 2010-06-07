#
# modules/nagios/manifests/definitions/nagios-local-service.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::local ($ensure=present, $export_for="", $service_description=false, $host_name=false, $check_command=false, $contact_groups=false, $normal_check_interval=false, $retry_check_interval=false, $package=false, $use="generic-service-active") {

  nagios_service {$name:
    ensure                => $ensure,
    use                   => $use,
    host_name             => $host_name ? {false => $hostname, default => $host_name},
    check_command         => $check_command ? {
      false   => $name,
      default => $check_command,
    },
    tag                   => $export_for ? {
                               ""      => "nagios-${fqdn}",
                               default => $export_for,
                             },
    service_description   => $service_description ? {false => undef, default => $service_description},
    contact_groups        => $contact_groups ? {false => undef, default => $contact_groups},
    normal_check_interval => $normal_check_interval ? {false => undef, default => $normal_check_interval},
    retry_check_interval  => $retry_check_interval ? {false => undef, default => $retry_check_interval},
    target                => "$nagios_cfg_dir/services.cfg",
    require               => [File["nagios_services.cfg"], Class["nagios::base"]],
    notify                => Exec["nagios-reload"],
  }

  if $package {
    if defined(Package["$package"]) {
      notice "$package already defined"
    } else {
      package {$package:
        ensure => present,
      }
    }
  }
}
