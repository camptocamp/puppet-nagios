/*
== Class: nagios::nsca::server

Installs and configures the nsca server and ensure it's up and running. This
class also collects the resources tagged with "nagios-${fqdn}". They typically
got exported using nagios::service::nsca.

Example usage:

  include nagios
  include nagios::nsca::server

*/
class nagios::nsca::server {

  include nagios::params

  # variables used in ERB template
  $basename = "${nagios::params::basename}"

  if !defined (Package["nsca"]) {
    package {"nsca":
      ensure => installed;
    }
  }

  service {"nsca":
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => false,
    pattern     => "/usr/sbin/nsca",
    require     => Package["nsca"],
  }

  Nagios_host    <<| tag == "nagios-${fqdn}" |>>
  Nagios_service <<| tag == "nagios-${fqdn}" |>>
  Nagios_command <<| tag == "nagios-${fqdn}" |>>
  File           <<| tag == "nagios-${fqdn}" |>>

  Nagios_host    { require => File["${nagios::params::resourcedir}"] }
  Nagios_service { require => File["${nagios::params::resourcedir}"] }
  Nagios_command { require => File["${nagios::params::resourcedir}"] }

  case $operatingsystem {
    /Debian|Ubuntu/: { $nagios_nsca_cfg = "/etc/nsca.cfg" }
    /RedHat|CentOS|Fedora/: { $nagios_nsca_cfg = "${nagios::params::rootdir}/nsca.cfg" }
  }

  file {"${nagios_nsca_cfg}":
    ensure  => present,
    owner   => root,
    group   => nagios,
    mode    => 640,
    content => template("nagios/nsca.cfg.erb"),
    require => [Package["nsca"], Package["nagios"]],
    notify  => Service["nsca"],
  }

}
