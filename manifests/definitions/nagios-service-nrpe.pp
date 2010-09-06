#
# modules/nagios/manifests/definitions/nagios-local-service.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::nrpe (
  $ensure=present,
  $service_description=undef,
  $export_for,
  $command_line,
  $host_name=false,
  $contact_groups=undef,
  $normal_check_interval=undef,
  $retry_check_interval=undef,
  $package=false
  ) {

  include nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  augeas { "set nrpe command ${name}":
    context   => "/files/etc/nagios/nrpe.cfg",
    changes   => "set command[.][./${name} =~ regexp('.*')]/${name} '${command_line}'",
    load_path => "/usr/share/augeas/lenses/contrib/",
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
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
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
