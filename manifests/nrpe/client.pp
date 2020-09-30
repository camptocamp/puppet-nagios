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
class nagios::nrpe::client (
  Enum['present', 'absent'] $ensure = 'present',
) {
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

  $package_name = $::osfamily ? {
    'Debian' => 'nagios-nrpe-server',
    'RedHat' => 'nrpe',
  }

  $service_name = $::osfamily ? {
    'Debian' => 'nagios-nrpe-server',
    'RedHat' => 'nrpe',
  }

  package { 'nrpe':
    ensure => $pkg_ensure,
    name   => $package_name,
  }

  $nologin_path = $::osfamily ? {
    'Debian' => '/usr/sbin/nologin',
    'RedHat' => '/sbin/nologin',
  }

  user{ 'nrpe':
    ensure  => $ensure,
    shell   => $nologin_path,
    require => Package['nrpe'],
  }

  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == '7' {
    $provider = 'redhat'
  } else {
    $provider = undef
  }

  if $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == '6' {
    $hasstatus = false
  } else {
    $hasstatus = undef
  }

  $svc_ensure = $ensure ? {
    present => running,
    absent  => stopped,
  }

  $svc_enable = $ensure ? {
    present => true,
    absent  => false,
  }

  service { 'nrpe':
    ensure    => $svc_ensure,
    provider  => $provider,
    hasstatus => $hasstatus,
    name      => $service_name,
    enable    => $svc_enable,
    pattern   => '/usr/sbin/nrpe',
    require   => Package['nrpe'],
  }

  $module_path = get_module_path($module_name)
  augeas::lens { 'nrpe':
    ensure       => $ensure,
    lens_content => file("${module_path}/files/nrpe.aug"),
    stock_since  => '1.1.0',
  }

}
