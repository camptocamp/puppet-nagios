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
    source => "puppet:///nagios/nrpe.aug",
  }

}
