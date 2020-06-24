# == Class: nagios::nsca::server
#
# Installs and configures the nsca server and ensure it's up and running. This
# class also collects the resources tagged with "nagios-${fqdn}". They typically
# got exported using nagios::service::nsca.
#
# Example usage:
#
#   include nagios
#   include nagios::nsca::server
#
class nagios::nsca::server(
  Enum['present', 'absent'] $ensure = 'present',
  $decryption_method = '0',

  $debug = 0,
) {

  include ::nagios::params

  case $ensure {
    'present': {
      $pkg_ensure = $ensure
    }

    default: {
      $pkg_ensure = $::osfamily ? {
        'RedHat' => 'absent',
        'Debian' => 'purged',
      }
    }
  }

  # variables used in ERB template
  $basename = $nagios::params::basename

  if !defined (Package['nsca']) {
    package {'nsca':
      ensure => $pkg_ensure;
    }
  }

  $svc_ensure = $nagios::ensure ? {
    present => running,
    default => stopped,
  }

  $svc_enable = $nagios::ensure ? {
    present => true,
    default => false,
  }

  service {'nsca':
    ensure     => $svc_ensure,
    enable     => $svc_enable,
    hasrestart => true,
    hasstatus  => false,
    pattern    => '/usr/sbin/nsca',
    require    => Package['nsca'],
  }

  if $ensure == 'present' {
    $get_tag = "nagios-${::nagios::nsca_server_tag}"

    Nagios::Host   <<| tag == $get_tag |>>
    Nagios_service <<| tag == $get_tag |>>
    Nagios_command <<| tag == $get_tag |>>
    File           <<| tag == $get_tag |>>
  }

  Nagios_host    { require => File[$nagios::params::resourcedir] }
  Nagios_service { require => File[$nagios::params::resourcedir] }
  Nagios_command { require => File[$nagios::params::resourcedir] }

  $nsca_group = $::osfamily ? {
    'Debian' => 'nogroup',
    'RedHat' => 'nagios',
  }

  $nagios_nsca_cfg = $::osfamily ? {
    'Debian' => '/etc/nsca.cfg',
    'RedHat' => "${nagios::params::rootdir}/nsca.cfg",
  }

  $command_file = $::osfamily ? {
    'Debian' => '/var/lib/nagios3/rw/nagios.cmd',
    'RedHat' => '/var/spool/nagios/cmd/nagios.cmd',
  }

  $alternate_dump_file = $::osfamily ? {
    'Debian' => '/var/run/nagios/nsca.dump',
    'RedHat' => '/var/spool/nagios/cmd/nsca.dump',
  }

  $file_ensure = $nagios::ensure ? {
    present => file,
    default => absent,
  }

  file {$nagios_nsca_cfg:
    ensure  => $file_ensure,
    owner   => root,
    group   => nagios,
    mode    => '0640',
    content => template('nagios/nsca.cfg.erb'),
    require => [Package['nsca'], Package['nagios']],
    notify  => Service['nsca'],
  }

}
