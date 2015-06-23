# == Definition: nagios::service::local
#
# Define a service resource on the local nagios instance.
#
# Example:
#
#   nagios::service::local { 'check process':
#     ensure                => present,
#     command_line          => '$USER1$/check_procs',
#     normal_check_interval => 5,
#     package               => 'nagios-plugins-procs',
#   }

define nagios::service::local (
  $command_line,
  $codename,
  $ensure=present,
  $service_description=undef,
  $host_name=false,
  $check_command=false,
  $contact_groups=undef,
  $service_groups=undef,
  $normal_check_interval=undef,
  $retry_check_interval=undef,
  $max_check_attempts=undef,
  $package=false,
  $use='generic-service-active',
  ) {

  include ::nagios::params

  $fname = regsubst($name, '\W', '_', 'G')

  $nagios_service_host_name     = $host_name ? {
    false   => $::fqdn,
    default => $host_name,
  }
  $nagios_service_check_command = $check_command ? {
    false   => $name,
    default => $check_command,
  }

  nagios_service { $name:
    ensure                => $ensure,
    use                   => $use,
    host_name             => $nagios_service_host_name,
    check_command         => $nagios_service_check_command,
    service_description   => $service_description,
    contact_groups        => $contact_groups,
    servicegroups         => $service_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    max_check_attempts    => $max_check_attempts,
    target                => "${nagios::params::resourcedir}/service-${fname}.cfg",
    require               => Nagios::Command[$codename],
    notify                => Exec['nagios-restart'],
  }

  file { "${nagios::params::resourcedir}/service-${fname}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    before => Nagios_service[$name],
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
