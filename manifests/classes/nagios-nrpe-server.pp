class nagios::nrpe::server {
  case $operatingsystem {
    
    /Debian|Ubuntu/: {
      package {"nagios-nrpe-plugin":
        ensure => present,
      }
    }
    /RedHat|CentOS|Fedora/: {
      package {"nagios-plugins-nrpe":
        ensure => present,
      }
    }

    default: {err ("operatingsystem $operatingsystem not yet implemented !")}
  }

  Nagios_host    <<| tag == "nagios-${fqdn}" |>>
  Nagios_service <<| tag == "nagios-${fqdn}" |>>
  Nagios_command <<| tag == "nagios-${fqdn}" |>>

  Nagios_host    { require => File["${nagios::params::resourcedir}"] }
  Nagios_service { require => File["${nagios::params::resourcedir}"] }
  Nagios_command { require => File["${nagios::params::resourcedir}"] }

}
