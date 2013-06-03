/*
== Definition: nagios::service::nrpe

Define a command in the local nrpe server configuration, and export the
associated nagios service and command resources to a remote nagios instance.

Example:

  nagios::service::nrpe { "check process":
    ensure => present,
    command_line => '/usr/lib/nagios/plugins/check_procs',
    normal_check_interval => 5,
    package => 'nagios-plugins-procs',
    export_for => "nagios-nrpe.example.com",
  }

*/
define nagios::service::nrpe (
  $ensure=present,
  $service_description=undef,
  $export_for,
  $command_line,
  $host_name=false,
  $contact_groups=undef,
  $service_groups=undef,
  $normal_check_interval=undef,
  $retry_check_interval=undef,
  $max_check_attempts=undef,
  $package=false
  ) {

  include nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  nrpe_command {$name:
    ensure  => present,
    command => $command_line,
    notify    => Service["nrpe"],
    require   => Package["nrpe"],
  }

  @@nagios_service { "@@$name on $hostname":
    ensure                => $ensure,
    use                   => "generic-service-active",
    host_name             => $host_name ? {
      false   => $hostname,
      default => $host_name,
    },
    check_command         => "nrpe_${name}_on_${hostname}",
    tag                   => $export_for,
    service_description   => $service_description,
    contact_groups        => $contact_groups,
    servicegroups         => $service_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    max_check_attempts    => $max_check_attempts,
    target                => "${nagios::params::resourcedir}/collected-service-${fname}_on_${hostname}.cfg",
    require               => Nagios_command["nrpe_${name}_on_${hostname}"],
    notify                => Exec["nagios-restart"],
  }

  @@file { "${nagios::params::resourcedir}/collected-service-${fname}_on_${hostname}.cfg":
    ensure => $ensure,
    owner  => "root",
    mode   => 0644,
    tag    => $export_for,
  }

  @@nagios_command { "nrpe_${name}_on_${hostname}":
    ensure       => $ensure,
    command_line => "\$USER1\$/check_nrpe -H ${fqdn} -u -t 120 -c ${name}",
    target       => "${nagios::params::resourcedir}/collected-command-nrpe_${fname}_on_${hostname}.cfg",
    tag          => $export_for,
    notify       => Exec["nagios-restart"],
  }

  @@file { "${nagios::params::resourcedir}/collected-command-nrpe_${fname}_on_${hostname}.cfg":
    ensure => $ensure,
    owner  => "root",
    mode   => 0644,
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
