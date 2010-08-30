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

  include nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  nagios::service::local { $name:
    ensure       => $ensure,
    use          => $use_active,
    command_line => $command_line,
    host_name    => $host_name ? {
      false   => $hostname,
      default => $host_name,
    },
    contact_groups        => $contact_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    service_description   => $service_description,
  }

  @@nagios_service { "@@$name on $hostname":
    ensure    => $ensure,
    use       => $use_passive,
    host_name => $host_name ? {
      false   => $hostname,
      default => $host_name,
    },
    tag       => $export_for,
    target    => "${nagios::params::resourcedir}/collected-service-${fname}_on_${hostname}.cfg",
    notify    => Exec["nagios-reload"],
    contact_groups        => $contact_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    service_description   => $service_description,
  }

  @@file { "${nagios::params::resourcedir}/collected-service-${fname}_on_${hostname}.cfg":
    ensure => $ensure,
    tag    => $export_for,
    before => Nagios_service["@@$name on $hostname"],
  }

  if $package {
    if !defined(Package[$package]) {
      package { $package:
        ensure => present,
      }
    }
  }
}
