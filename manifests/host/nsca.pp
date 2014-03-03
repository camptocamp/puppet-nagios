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

  include nagios::params

  $fname               = regsubst($name, '\W', '_', 'G')
  $nagios_host_address = $address ? {
    false   => $::ipaddress,
    default => $address,
  }

  nagios_host { $name:
    ensure  => $ensure,
    use     => 'generic-host-active',
    address => $nagios_host_address,
    alias   => $nagios_alias,
    target  => "${nagios::params::resourcedir}/host-${fname}.cfg",
    notify  => Exec['nagios-restart'],
  }

  file { "${nagios::params::resourcedir}/host-${fname}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    before => Nagios_host[$name],
  }

  @@nagios_host { "@@${name}":
    ensure         => $ensure,
    use            => 'generic-host-passive',
    address        => $nagios_host_address,
    host_name      => $name,
    alias          => $nagios_alias,
    tag            => $export_for,
    hostgroups     => $hostgroups,
    target         => "${nagios::params::resourcedir}/collected-host-${fname}.cfg",
    contact_groups => $contact_groups,
    notify         => Exec['nagios-restart'],
  }

  @@file { "${nagios::params::resourcedir}/collected-host-${fname}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    tag    => $export_for,
  }

}
