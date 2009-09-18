class nagios::nrpe::server {
  case $operatingsystem {
    
    Debian: {
      package {"nagios-nrpe-plugin":
        ensure => present,
      }
    }

    RedHat: {
      package {"nagios-plugins-nrpe":
        ensure => present,
      }
    }

    default: {err ("operatingsystem $operatingsystem not yet implemented !")}
  }
}
