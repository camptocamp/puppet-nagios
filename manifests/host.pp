# == Definition: nagios::host
#
# Define a host resource on the local nagios instance.
#
# Example:
#
#   nagios::host { $fqdn:
#     ensure => "present",
#   }

define nagios::host (
  $ensure=present,
  $address=false,
  $nagios_alias=undef,
  $hostgroups=undef,
  $contact_groups=undef,
  $use='generic-host-active',
  ) {

  include ::nagios::params

  $fname = regsubst($name, '\W', '_', 'G')
  $nagios_address = $address ? {
    false   => $::ipaddress,
    default => $address,
  }

  nagios_host { $name:
    ensure         => $ensure,
    use            => $use,
    address        => $nagios_address,
    # lint:ignore:alias_parameter
    alias          => $nagios_alias,
    # lint:endignore
    hostgroups     => $hostgroups,
    contact_groups => $contact_groups,
    target         => "${nagios::params::resourcedir}/host-${fname}.cfg",
    notify         => Exec['nagios-restart'],
  }

  file { "${nagios::params::resourcedir}/host-${fname}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    before => Nagios_host[$name],
  }

}
