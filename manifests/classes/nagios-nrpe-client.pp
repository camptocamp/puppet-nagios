class nagios::nrpe::client {

  package { "nrpe":
    name    => $operatingsystem ? {
      /Debian|Ubuntu/ => "nagios-nrpe-server",
      /RedHat|CentOS/ => "nrpe",
    },
    ensure  => present,
  }

  service { "nrpe":
    name    => $operatingsystem ? {
      /Debian|Ubuntu/ => "nagios-nrpe-server",
      /RedHat|CentOS/ => "nrpe",
    },
    ensure  => running,
    require => Package["nrpe"],
  }

}
