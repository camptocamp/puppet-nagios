# == Definition: nagios::service::remote
#
# Define a service resource on a remote nagios instance using exported
# resources.
#
# Example:
#
#   nagios::service::remote { "check ssh":
#     ensure => present,
#     command_line => '/usr/lib/nagios/plugins/check_ssh',
#     normal_check_interval => 5,
#     export_for => "nagios-nsca.example.com",
#   }
#
define nagios::service::remote (
  $export_for,
  $command_line,
  $ensure                = present,
  $service_description   = undef,
  $host_name             = false,
  $contact_groups        = undef,
  $service_groups        = undef,
  $normal_check_interval = undef,
  $retry_check_interval  = undef,
  $max_check_attempts    = undef,
) {

  include ::nagios::params

  $fname = regsubst($name, '\W', '_', 'G')

  $nagios_host_name = $host_name ? {
    false   => $::fqdn,
    default => $host_name,
  }

  @@nagios_service { "@@${name} on ${::fqdn}":
    ensure                => $ensure,
    use                   => 'generic-service-active',
    host_name             => $nagios_host_name,
    check_command         => "${name}_on_${::fqdn}",
    tag                   => $export_for,
    service_description   => $service_description,
    contact_groups        => $contact_groups,
    servicegroups         => $service_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    max_check_attempts    => $max_check_attempts,
    target                => "${nagios::params::resourcedir}/collected-service-${fname}_on_${::fqdn}.cfg",
    require               => Nagios_command["${name}_on_${::fqdn}"],
    notify                => Exec['nagios-restart'],
  }

  @@file { "${nagios::params::resourcedir}/collected-service-${fname}_on_${::fqdn}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    tag    => $export_for,
  }

  @@nagios_command { "${name}_on_${::fqdn}":
    ensure       => $ensure,
    command_line => $command_line,
    target       => "${nagios::params::resourcedir}/collected-command-${fname}_on_${::fqdn}.cfg",
    tag          => $export_for,
    notify       => Exec['nagios-restart'],
  }

  @@file { "${nagios::params::resourcedir}/collected-command-${fname}_on_${::fqdn}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    tag    => $export_for,
  }

}
