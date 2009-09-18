class nagios::nrpe::client {
  case $operatingsystem {
  
    Debian: {
      package {"nagios-nrpe-server":
        ensure => present,
      }
    }

    RedHat: {
      package {"nrpe":
        ensure => present,
      }
    }

    default: {err ("operatingsystem $operatingsystem not yet implemented !")}
  
  }
}
