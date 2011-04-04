/*
== Class: nagios::nrpe::server

Installs the check_nrpe plugin and collects the resources tagged with
"nagios-${fqdn}". They typically got exported using nagios::service::nrpe.

NB: the class name can be confusing. The idea is that central nodes are nagios
"servers", even if they just execute plugins.

Example usage:

  include nagios
  include nagios::nrpe::server

*/
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
  File           <<| tag == "nagios-${fqdn}" |>>

  Nagios_host    { require => File["${nagios::params::resourcedir}"] }
  Nagios_service { require => File["${nagios::params::resourcedir}"] }
  Nagios_command { require => File["${nagios::params::resourcedir}"] }

}
