# == Definition: nagios::host::nsca
#
# Define a host resource on the local nagios instance and export the same
# resource to a remote nagios nsca server.
#
# Example:
#
#   nagios::host::nsca { $fqdn:
#     ensure     => "present",
#     export_for => "nagios-nsca.example.com",
#   }
#
define nagios::host::nsca (
  $export_for,
  $ensure=present,
  $address=false,
  $nagios_alias=undef,
  $hostgroups=undef,
  $contact_groups=undef
  ) {

  include ::nagios::params

  $fname = regsubst($name, '\W', '_', 'G')
  $nagios_host_address = $address ? {
    false   => $::ipaddress,
    default => $address,
  }

  nagios_host {$name:
    ensure  => $ensure,
    use     => 'generic-host-active',
    address => $nagios_host_address,
    # lint:ignore:alias_parameter
    alias   => $nagios_alias,
    # lint:endignore
    target  => "${nagios::params::resourcedir}/host-${fname}.cfg",
    notify  => Exec['nagios-restart'],
  }

  file { "${nagios::params::resourcedir}/host-${fname}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    before => Nagios_host[$name],
  }

  @@nagios::host {$name:
    ensure         => $ensure,
    address        => $nagios_host_address,
    nagios_alias   => $nagios_alias,
    hostgroups     => $hostgroups,
    contact_groups => $contact_groups,
    use            => 'generic-host-passive',
    tag            => $export_for,
  }

}
