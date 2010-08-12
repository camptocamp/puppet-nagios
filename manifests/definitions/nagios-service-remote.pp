#
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::remote (
  $ensure=present,
  $export_for,
  $command_line,
  $service_description=undef,
  $host_name=false,
  $contact_groups=undef,
  $normal_check_interval=undef,
  $retry_check_interval=undef
  ) {

  @@nagios_service {"@@${name} on ${hostname}":
    ensure                => $ensure,
    use                   => "generic-service-active",
    host_name             => $host_name ? {
      false => $hostname,
      default => $host_name,
    },
    check_command         => "${name}_on_${hostname}",
    tag                   => $export_for,
    service_description   => $service_description,
    contact_groups        => $contact_groups,
    normal_check_interval => $normal_check_interval,
    retry_check_interval  => $retry_check_interval,
    target                => "${nagios_cfg_dir}/services.cfg",
    require               => [
      Class["nagios::base"],
      File["nagios_services.cfg"],
      Nagios_command["${name}_on_${hostname}"],
    ],
    notify                => Exec["nagios-reload"],
  }

  @@nagios_command {"${name}_on_${hostname}":
    ensure       => $ensure,
    command_line => $command_line,
    target       => "${nagios_cfg_dir}/commands.cfg",
    tag          => $export_for,
    require      => [
      Class["nagios::base"],
      File["nagios_commands.cfg"],
    ],
    notify       => Exec["nagios-reload"],
  }

}
