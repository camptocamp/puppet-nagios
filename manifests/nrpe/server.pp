# == Class: nagios::nrpe::server
#
# Installs the check_nrpe plugin and collects the resources tagged with
# "nagios-${::fqdn}". They typically got exported using nagios::service::nrpe.
#
# NB: the class name can be confusing. The idea is that central nodes are nagios
# "servers", even if they just execute plugins.
#
# Example usage:
#
#   include nagios
#   include nagios::nrpe::server
#
class nagios::nrpe::server (
  Enum['present', 'absent'] $ensure = 'present',
) {
  include ::nagios::params

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

  case $::osfamily {
    'Debian': {
      package {'nagios-nrpe-plugin':
        ensure => $pkg_ensure,
      }
    }
    'RedHat': {
      package {'nagios-plugins-nrpe':
        ensure => $pkg_ensure,
      }
    }

    default: { fail ("OS family ${::osfamily} not yet implemented !")}
  }

  if $ensure == 'present' {
    $get_tag = "nagios-${::nagios::nrpe_server_tag}"

    Nagios::Host   <<| tag == $get_tag |>>
    Nagios_service <<| tag == $get_tag |>>
    Nagios_command <<| tag == $get_tag |>>
    File           <<| tag == $get_tag |>>

    Nagios_host    { require => File[$nagios::params::resourcedir] }
    Nagios_service { require => File[$nagios::params::resourcedir] }
    Nagios_command { require => File[$nagios::params::resourcedir] }
  }
}
