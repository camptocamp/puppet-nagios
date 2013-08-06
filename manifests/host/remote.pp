/*
== Definition: nagios::host::remote

Define a host resource on the local nagios instance and export the same
resource to a remote nagios server.

Example:

  nagios::host::remote { $fqdn:
    ensure     => "present",
    export_for => "nagios-nsca.example.com",
  }

*/
define nagios::host::remote (
  $export_for,
  $ensure=present,
  $address=false,
  $nagios_alias=undef,
  $hostgroups=undef,
  $contact_groups=undef
  ) {

  include ::nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  nagios_host { $name:
    ensure  => $ensure,
    use     => 'generic-host-active',
    address => $address ? {
      false   => $::ipaddress,
      default => $address,
    },
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
    use            => 'generic-host-active',
    tag            => $export_for,
    host_name      => $name,
    address        => $address ? {
      false   => $::ipaddress,
      default => $address,
    },
    alias          => $nagios_alias,
    hostgroups     => $hostgroups,
    contact_groups => $contact_groups,
    target         => "${nagios::params::resourcedir}/collected-host-${fname}.cfg",
    notify         => Exec['nagios-restart'],
  }

  @@file { "${nagios::params::resourcedir}/collected-host-${fname}.cfg":
    ensure => $ensure,
    owner  => 'root',
    mode   => '0644',
    tag    => $export_for,
  }

}
