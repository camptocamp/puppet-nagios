# == Class: nagios::nsca::client
#
# Installs the nsca client and configures nagios to send status information to
# the central nsca server.
#
# Example usage:
#
#   include nagios
#   include nagios::nsca::client
#
class nagios::nsca::client(
  $nsca_server,
  Enum['present', 'absent'] $ensure = 'present',
) {

  include ::nagios::params

  if !defined (Package['nsca']) {
    package {'nsca':
      ensure => $ensure;
    }
  }

  if $::osfamily == 'RedHat' {
    if !defined (Package['nsca-client']) {
      package { 'nsca-client': ensure => $ensure }
    }
  }

  # variables used in ERB template
  $nsca_cfg = "${nagios::params::rootdir}/send_nsca.cfg"

  $file_ensure = $nagios::ensure ? {
    present => file,
    default => absent,
  }

  file { "${nagios::params::rootdir}/send_nsca.cfg":
    ensure  => $file_ensure,
    owner   => root,
    group   => nagios,
    mode    => '0640',
    content => template('nagios/send_nsca.cfg.erb'),
    require => [Package['nsca'], Package['nagios']],
    notify  => Service['nagios'],
  }

  file {'/usr/local/bin/submit_ocsp':
    ensure  => $file_ensure,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('nagios/submit_ocsp.erb'),
    require => File["${nagios::params::rootdir}/send_nsca.cfg"],
  }

  file {'/usr/local/bin/submit_ochp':
    ensure  => $file_ensure,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('nagios/submit_ochp.erb'),
    require => File["${nagios::params::rootdir}/send_nsca.cfg"],
  }

  file { "${nagios::params::resourcedir}/command-submit_ocsp.cfg":
    ensure => $file_ensure,
    owner  => 'root',
    mode   => '0644',
  }

  nagios_command {'submit_ocsp':
    ensure       => $ensure,
    command_line => '/usr/local/bin/submit_ocsp $HOSTNAME$ \'$SERVICEDESC$\' $SERVICESTATEID$ \'$SERVICEOUTPUT$\'',
    target       => "${nagios::params::resourcedir}/command-submit_ocsp.cfg",
    notify       => Exec['nagios-restart'],
    require      => File["${nagios::params::resourcedir}/command-submit_ocsp.cfg"],
  }

  file { "${nagios::params::resourcedir}/command-submit_ochp.cfg":
    ensure => $file_ensure,
    owner  => 'root',
    mode   => '0644',
  }

  nagios_command {'submit_ochp':
    ensure       => $ensure,
    command_line => '/usr/local/bin/submit_ochp $HOSTNAME$ $HOSTSTATE$ \'$HOSTOUTPUT$\'',
    target       => "${nagios::params::resourcedir}/command-submit_ochp.cfg",
    notify       => Exec['nagios-restart'],
    require      => File["${nagios::params::resourcedir}/command-submit_ochp.cfg"],
  }

  concat::fragment {'submit_ocsp':
    target  => $nagios::params::conffile,
    content => "ocsp_command=submit_ocsp\n",
  }

  concat::fragment {'submit_ochp':
    target  => $nagios::params::conffile,
    content => "ochp_command=submit_ochp\n",
  }

  #TODO: remove this resource in a while
  file { '/etc/send_nsca.cfg': ensure => absent }

}
