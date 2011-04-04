/*
== Definition: nagios::service::remote

Define a service resource on a remote nagios instance using exported resources.

Example:

  nagios::service::remote { "check ssh":
    ensure => present,
    command_line => '/usr/lib/nagios/plugins/check_ssh',
    normal_check_interval => 5,
    export_for => "nagios-nsca.example.com",
  }

*/
define nagios::service::remote (
  $ensure=present,
  $export_for,
  $command_line,
  $service_description=undef,
  $host_name=false,
  $contact_groups=undef,
  $service_groups=undef,
  $normal_check_interval=undef,
  $retry_check_interval=undef
  ) {

  include nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  @@nagios_service { "@@${name} on ${hostname}":
    ensure                => $ensure,
    use                   => "generic-service-active",
    host_name             => $host_name ? {
      false   => $hostname,
      default => $host_name,
    },
    check_command         => "${name}_on_${hostname}",
    tag                   => $export_for,
    service_description   => $service_description,
    contact_groups        => $contact_groups,
    servicegroups         => $service_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    target                => "${nagios::params::resourcedir}/collected-service-${fname}_on_${hostname}.cfg",
    require               => Nagios_command["${name}_on_${hostname}"],
    notify                => Exec["nagios-restart"],
  }

  @@file { "${nagios::params::resourcedir}/collected-service-${fname}_on_${hostname}.cfg":
    ensure => $ensure,
    owner  => "root",
    mode   => 0644,
    tag    => $export_for,
  }

  @@nagios_command { "${name}_on_${hostname}":
    ensure       => $ensure,
    command_line => $command_line,
    target       => "${nagios::params::resourcedir}/collected-command-${fname}_on_${hostname}.cfg",
    tag          => $export_for,
    notify       => Exec["nagios-restart"],
  }

  @@file { "${nagios::params::resourcedir}/collected-command-${fname}_on_${hostname}.cfg":
    ensure => $ensure,
    owner  => "root",
    mode   => 0644,
    tag    => $export_for,
  }

}
