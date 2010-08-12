#
# modules/nagios/manifests/definitions/nagios-local-service.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::nrpe (
  $ensure=present,
  $service_description=false,
  $export_for,
  $command_line,
  $host_name=false,
  $contact_groups=false,
  $normal_check_interval=false,
  $retry_check_interval=false
  ) {

  augeas { "set nrpe command ${name}":
    context   => "/files/etc/nagios/nrpe.cfg",
    changes   => "set command[.][./${name} =~ regexp('.*')]/${name} '${command_line}'",
    load_path => "/usr/share/augeas/lenses/contrib/",
    notify    => Service["nrpe"],
    require   => Package["nrpe"],
  }

  @@nagios_service {"@@$name on $hostname":
    ensure                => $ensure,
    use                   => "generic-service-active",
    host_name             => $host_name ? {false => $hostname, default => $host_name},
    check_command         => "nrpe_${name}_on_${hostname}",
    tag                   => $export_for,
    service_description   => $service_description ? {false => undef, default => $service_description},
    contact_groups        => $contact_groups ? {false => undef, default => $contact_groups},
    normal_check_interval => $normal_check_interval ? {false => undef, default => $normal_check_interval},
    retry_check_interval  => $retry_check_interval ? {false => undef, default => $retry_check_interval},
    target                => "${nagios_cfg_dir}/services.cfg",
    require               => [
      Class["nagios::base"],
      File["nagios_services.cfg"],
      Nagios_command["nrpe_${name}_on_${hostname}"],
    ],
    notify                => Exec["nagios-reload"],
  }

  @@nagios_command {"nrpe_${name}_on_${hostname}":
    ensure       => $ensure,
    command_line => "\$USER1\$/check_nrpe -H ${fqdn} -u -t 120 -c ${name}",
    target       => "${nagios_cfg_dir}/commands.cfg",
    tag          => $export_for,
    require      => [
      Class["nagios::base"],
      File["nagios_commands.cfg"],
    ],
    notify       => Exec["nagios-reload"],
  }

}
