# == Definition: nagios::local::hostgroup
#
# Define a hostgroup resource on the local nagios instance.
#
# Example:
#
#   nagios::local::hostgroup { "my-hostgroup":
#     ensure => present,
#   }
#
define nagios::local::hostgroup ($ensure=present) {

  include nagios::params

  $fname = regsubst($name, '\W', '_', 'G')

  nagios_hostgroup { $name:
    ensure => $ensure,
    target => "${nagios::params::resourcedir}/hostgroup-${fname}.cfg",
    notify => Exec['nagios-restart'],
  }

  file { "${nagios::params::resourcedir}/hostgroup-${fname}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    before => Nagios_hostgroup[$name],
  }

}
