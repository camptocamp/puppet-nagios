#
# modules/nagios/manifests/definitions/nagios-local-service.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::local (
  $ensure=present,
  $command_line,
  $service_description=undef,
  $host_name=false,
  $check_command=false,
  $contact_groups=undef,
  $normal_check_interval=undef,
  $retry_check_interval=undef,
  $package=false,
  $use="generic-service-active"
  ) {

  include nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  nagios_service { $name:
    ensure                => $ensure,
    use                   => $use,
    host_name             => $host_name ? {
      false   => $hostname,
      default => $host_name,
    },
    check_command         => $check_command ? {
      false   => $name,
      default => $check_command,
    },
    service_description   => $service_description,
    contact_groups        => $contact_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    target                => "${nagios::params::resourcedir}/service-${fname}.cfg",
    require               => [
      Class["nagios::base"],
      File["nagios_services.cfg"],
      Nagios::Command[$codename],
    ],
    notify                => Exec["nagios-reload"],
  }

  file { "${nagios::params::resourcedir}/service-${fname}.cfg":
    ensure => $ensure,
  }

  nagios::command { $codename:
    ensure       => $ensure,
    command_line => $command_line,
  }

  if $package {
    if !defined(Package[$package]) {
      package { $package:
        ensure => present,
      }
    }
  }
}
