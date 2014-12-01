# == Class: nagios::nrpe::client
#
# Installs nrpe and ensures the service is up and running.
#
# NB: the class name can be confusing. The idea is that leaf nodes are nagios
# "clients", even if they run a service such as nrpe.
#
# Example usage:
#
#   include nagios
#   include nagios::nrpe::client
#
class nagios::nrpe::client {

  $package_name = $::osfamily ? {
    'Debian' => 'nagios-nrpe-server',
    'RedHat' => 'nrpe',
  }

  $service_name = $::osfamily ? {
    'Debian' => 'nagios-nrpe-server',
    'RedHat' => 'nrpe',
  }

  package { 'nrpe':
    ensure => present,
    name   => $package_name,
  }

  service { 'nrpe':
    ensure  => running,
    name    => $service_name,
    enable  => true,
    pattern => '/usr/sbin/nrpe',
    require => Package['nrpe'],
  }

  augeas::lens { 'nrpe':
    ensure      => 'present',
    lens_source => 'puppet:///modules/nagios/nrpe.aug',
    stock_since => '1.1.0',
  }

}
