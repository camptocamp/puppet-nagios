# == Class: nagios::debian
#
# Define common resources specific to debian based systems. It shouldn't be
# necessary to include this class directly. Instead, you should use:
#
#   include nagios
#
class nagios::debian inherits nagios::base {
  assert_private()

  include ::nagios::params

  # Common resources between base, redhat, and debian

  $pkg_ensure = $nagios::ensure ? {
    present => installed,
    default => purged,
  }

  package {[
    'nagios3-common',
    'nagios-plugins',
    'nagios-plugins-standard',
    'nagios-plugins-basic',
    ]:
    ensure => $pkg_ensure,
  }
  package {'nagios':
    ensure => $pkg_ensure,
    name   => 'nagios3-core',
  }

  Service['nagios'] {
    name => 'nagios3',
  }

  File['/var/lib/nagios3'] {
    mode => '0751',
  }


  # debian specific resources below
  $niceness = $nagios::niceness

  $file_ensure = $nagios::ensure ? {
    present => file,
    default => absent,
  }

  file {'/etc/default/nagios3':
    ensure  => $file_ensure,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('nagios/etc/default/nagios3.erb'),
    require => Package['nagios'],
  }

}
