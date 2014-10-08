# == Definition: nagios::command
#
# Simple wrapper to create a nagios_command resource and associated file.
#
# Example:
#
#   nagios::command { "check_service":
#     command_line => "/usr/lib/nagios/plugins/check_dummy 0 ok"
#   }

define nagios::command (
  $command_line,
  $ensure        = present,
  ) {

  include nagios::params

  $fname = regsubst($name, '\W', '_', 'G')

  nagios_command { $name:
    ensure       => $ensure,
    command_line => $command_line,
    target       => "${nagios::params::resourcedir}/command-${fname}.cfg",
    notify       => Exec['nagios-restart'],
  }

  file { "${nagios::params::resourcedir}/command-${fname}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    before => Nagios_command[$name],
  }

}
