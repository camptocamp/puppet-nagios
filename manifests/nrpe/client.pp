/*
== Class: nagios::nrpe::client

Installs nrpe and ensures the service is up and running.

NB: the class name can be confusing. The idea is that leaf nodes are nagios
"clients", even if they run a service such as nrpe.

Example usage:

  include nagios
  include nagios::nrpe::client

*/
class nagios::nrpe::client {

  package { "nrpe":
    name    => $operatingsystem ? {
      /Debian|Ubuntu/ => "nagios-nrpe-server",
      /RedHat|CentOS|Fedora/ => "nrpe",
    },
    ensure  => present,
  }

  service { "nrpe":
    name    => $operatingsystem ? {
      /Debian|Ubuntu/ => "nagios-nrpe-server",
      /RedHat|CentOS|Fedora/ => "nrpe",
    },
    ensure  => running,
    enable  => true,
    pattern => "/usr/sbin/nrpe",
    require => Package["nrpe"],
  }

  file { "/usr/share/augeas/lenses/contrib/nrpe.aug":
    ensure => present,
    source => "puppet:///modules/nagios/nrpe.aug",
  }

}
