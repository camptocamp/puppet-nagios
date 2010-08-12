#
# modules/nagios/manifests/definitions/nagios-local-service.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::local (
  $ensure=present,
  $command_line,
  $service_description=false,
  $host_name=false,
  $check_command=false,
  $contact_groups=false,
  $normal_check_interval=false,
  $retry_check_interval=false,
  $package=false,
  $use="generic-service-active"
  ) {

  nagios_service {$name:
    ensure                => $ensure,
    use                   => $use,
    host_name             => $host_name ? {false => $hostname, default => $host_name},
    check_command         => $check_command ? {
      false   => $name,
      default => $check_command,
    },
    service_description   => $service_description ? {false => undef, default => $service_description},
    contact_groups        => $contact_groups ? {false => undef, default => $contact_groups},
    normal_check_interval => $normal_check_interval ? {false => undef, default => $normal_check_interval},
    retry_check_interval  => $retry_check_interval ? {false => undef, default => $retry_check_interval},
    target                => "${nagios_cfg_dir}/services.cfg",
    require               => [
      Class["nagios::base"],
      File["nagios_services.cfg"],
      Nagios::Command[$codename],
    ],
    notify                => Exec["nagios-reload"],
  }

  nagios::command { $codename:
    ensure => $ensure,
    command_line => $command_line,
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
