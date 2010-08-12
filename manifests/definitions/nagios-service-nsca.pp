#
# modules/nagios/manifests/definitions/nagios-nsca-service.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::nsca (
  $ensure=present,
  $service_description=false,
  $export_for,
  $command_line,
  $host_name=false,
  $contact_groups=undef,
  $normal_check_interval=undef,
  $retry_check_interval=undef,
  $use_active="generic-service-active",
  $use_passive="generic-service-passive",
  $package=false
  ) {

  nagios::service::local {$name:
    ensure       => $ensure,
    use          => $use_active,
    command_line => $command_line,
    export_for   => $export_for,
    host_name    => $host_name ? {
      false => $hostname,
      default => $host_name,
    },
    contact_groups        => $contact_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    service_description   => $service_description,
  }

  @@nagios_service {"@@$name on $hostname":
    ensure    => $ensure,
    use       => $use_passive,
    host_name => $host_name ? {
      false => $hostname,
      default => $host_name,
    },
    tag       => $export_for,
    target    => "${nagios_cfg_dir}/services.cfg",
    notify    => Exec["nagios-reload"],
    contact_groups        => $contact_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    service_description   => $service_description,
    require   => [
      Class["nagios::base"],
      File["nagios_services.cfg"],
    ],
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
