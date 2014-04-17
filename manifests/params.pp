# == Class: nagios::params
#
# This class defines a few of attributes which are used in many classes and
# definitions of this module.
#
class nagios::params {

  $basename = $::osfamily ? {
    'Debian' => 'nagios3',
    'RedHat' => 'nagios',
  }

  $user1 = $::osfamily ? {
    'Debian' => '/usr/lib/nagios/plugins',
    'RedHat' => $::architecture ? {
      'x86_64' => '/usr/lib64/nagios/plugins',
      default  => '/usr/lib/nagios/plugins',
    },
  }

  $p1file = $::osfamily ? {
    'Debian' => '/usr/lib/nagios3/p1.pl',
    'RedHat' => '/usr/sbin/p1.pl',
  }

  $resourcedir = '/etc/nagios.d'
  $rootdir     = "/etc/${basename}"
  $conffile    = "${rootdir}/nagios.cfg"

  $nsca_server = $nagios_nsca_server
}
