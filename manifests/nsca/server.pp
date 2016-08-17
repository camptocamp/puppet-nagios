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
  $decryption_method = pick($nagios_nsca_decryption_method, '0'),

  $debug = 0,
) {

  include ::nagios::params

  # variables used in ERB template
  $basename = $nagios::params::basename

  if !defined (Package['nsca']) {
    package {'nsca':
      ensure => installed;
    }
  }

  service {'nsca':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => false,
    pattern    => '/usr/sbin/nsca',
    require    => Package['nsca'],
  }

  $get_tag = "nagios-${::nagios::nsca_server_tag}"

  Nagios::Host   <<| tag == $get_tag |>>
  Nagios_service <<| tag == $get_tag |>>
  Nagios_command <<| tag == $get_tag |>>
  File           <<| tag == $get_tag |>>

  Nagios_host    { require => File[$nagios::params::resourcedir] }
  Nagios_service { require => File[$nagios::params::resourcedir] }
  Nagios_command { require => File[$nagios::params::resourcedir] }

  $nagios_nsca_cfg = $::osfamily ? {
    'Debian' => '/etc/nsca.cfg',
    'RedHat' => "${nagios::params::rootdir}/nsca.cfg",
  }

  $command_file = $::osfamily ? {
    'Debian' => '/var/lib/nagios3/rw/nagios.cmd',
    'RedHat' => '/var/spool/nagios/cmd/nagios.cmd',
  }

  file {$nagios_nsca_cfg:
    ensure  => file,
    owner   => root,
    group   => nagios,
    mode    => '0640',
    content => template('nagios/nsca.cfg.erb'),
    require => [Package['nsca'], Package['nagios']],
    notify  => Service['nsca'],
  }

}
