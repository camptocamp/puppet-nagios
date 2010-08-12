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

  nagios_command {$name:
    ensure        => $ensure,
    command_line  => $command_line,
    target        => "${nagios_cfg_dir}/commands.cfg",
    notify        => Exec["nagios-reload"],
    require       => [
      Class["nagios::base"],
      File["nagios_commands.cfg"],
    ],
  }

}
