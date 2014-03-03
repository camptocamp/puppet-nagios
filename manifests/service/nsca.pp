# == Definition: nagios::service::nsca
#
# Define a service resource on the local nagios instance and export the same
# resource to a remote nagios nsca server.
#
# Example:
#
#   nagios::service::nsca { 'check process':
#     ensure                => present,
#     command_line          => '/usr/lib/nagios/plugins/check_procs',
#     normal_check_interval => 5,
#     package               => 'nagios-plugins-procs',
#     export_for            => 'nagios-nsca.example.com',
#   }
#
define nagios::service::nsca (
  $export_for,
  $command_line,
  $codename,
  $ensure                = present,
  $service_description   = false,
  $host_name             = false,
  $contact_groups        = undef,
  $service_groups        = undef,
  $normal_check_interval = undef,
  $retry_check_interval  = undef,
  $max_check_attempts    = undef,
  $use_active            = 'generic-service-active',
  $use_passive           = 'generic-service-passive',
  $package               = false,
  ) {

  include nagios::params

  $fname = regsubst($name, '\W', '_', 'G')

  $nagios_host_name = $host_name ? {
    false    => $::hostname,
    default  => $host_name,
  }

  nagios::service::local { $name:
    ensure                => $ensure,
    use                   => $use_active,
    command_line          => $command_line,
    codename              => $codename,
    host_name             => $nagios_host_name,
    contact_groups        => $contact_groups,
    service_groups        => $service_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    max_check_attempts    => $max_check_attempts,
    service_description   => $service_description,
  }

  @@nagios_service { "@@${name} on ${::hostname}":
    ensure                => $ensure,
    use                   => $use_passive,
    host_name             => $nagios_host_name,
    tag                   => $export_for,
    target                => "${nagios::params::resourcedir}/collected-service-${fname}_on_${::hostname}.cfg",
    notify                => Exec['nagios-restart'],
    contact_groups        => $contact_groups,
    servicegroups         => $service_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    max_check_attempts    => $max_check_attempts,
    service_description   => $service_description,
  }

  @@file { "${nagios::params::resourcedir}/collected-service-${fname}_on_${::hostname}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    tag    => $export_for,
  }

  if $package {
    if !defined(Package[$package]) {
      package { $package:
        ensure => present,
      }
    }
  }
}
