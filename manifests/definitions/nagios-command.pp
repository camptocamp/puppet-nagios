#
# modules/nagios/manifests/definitions/nagios-config-command.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::command (
  $ensure=present,
  $command_line
  ) {

  include nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  nagios_command { $name:
    ensure        => $ensure,
    command_line  => $command_line,
    target        => "${nagios::params::resourcedir}/command-${fname}.cfg",
    notify        => Exec["nagios-restart"],
  }

  file { "${nagios::params::resourcedir}/command-${fname}.cfg":
    ensure => $ensure,
    owner  => "root",
    mode   => 0644,
    before => Nagios_command[$name],
  }

}
