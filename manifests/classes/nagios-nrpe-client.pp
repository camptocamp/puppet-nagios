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
    enable  => true,
    require => Package["nrpe"],
  }

  file { "/usr/share/augeas/lenses/contrib/nrpe.aug":
    ensure => present,
    source => "puppet:///nagios/nrpe.aug",
  }

}
