# == Class: nagios::redhat
#
# Define common resources specific to redhat based systems. It shouldn't be
# necessary to include this class directly. Instead, you should use:
#
#   include nagios
#
class nagios::redhat inherits nagios::base {

  include ::nagios::params

  # Common resources between base, redhat, and debian

  package { 'nagios':
    ensure => present,
  }

  package { [
    'nagios-plugins',
    'nagios-plugins-procs',
    'nagios-plugins-disk',
    'nagios-plugins-load',
    'nagios-plugins-ping',
    'nrpe',
  ]:
    ensure => present,
  }

  # redhat specific resources below

  file {'/etc/default/nagios': ensure => absent }

  file {'/etc/nagios3': ensure => absent }

  case $::operatingsystemmajrelease {

    '5','6': {
      File[
        '/var/run/nagios',
        '/var/log/nagios',
        '/var/lib/nagios',
        '/var/lib/nagios/spool',
        '/var/lib/nagios/spool/checkresults',
        '/var/cache/nagios'
        ] {
        seltype => 'nagios_log_t',
      }

      File['nagios read-write dir'] {
        seltype => 'nagios_log_t',
      }

      if str2bool($::selinux) {
        exec { 'chcon /var/run/nagios/rw/nagios.cmd':
          require => [Exec['create fifo'], File['nagios read-write dir']],
          command => 'chcon -t nagios_spool_t /var/run/nagios/rw/nagios.cmd',
          unless  => 'ls -Z /var/run/nagios/rw/nagios.cmd | grep -q nagios_spool_t',
        }
      }

      Service['nagios'] {
        hasstatus   => false,
        pattern     => '/usr/sbin/nagios -d /etc/nagios/nagios.cfg',
      }

      file {[
        '/var/lib/nagios/retention.dat',
        '/var/cache/nagios/nagios.tmp',
        '/var/cache/nagios/status.dat',
        '/var/cache/nagios/objects.precache',
        '/var/cache/nagios/objects.cache',
      ]:
        ensure   => file,
        seltype  => 'nagios_log_t',
        owner    => 'nagios',
        group    => 'nagios',
        loglevel => 'debug',
        require  => File['/var/run/nagios'],
      }
      File['/var/lib/nagios/retention.dat'] { mode => '0600', }
      File['/var/cache/nagios/status.dat']  { mode => '0664', }

      # workaround broken init-script
      Exec['nagios-restart'] {
        command => "nagios -v ${nagios::params::conffile} && pkill -P 1 -f '^/usr/sbin/nagios' && /etc/init.d/nagios start",
      }

      Exec['nagios-reload'] {
        command => "nagios -v ${nagios::params::conffile} && pkill -P 1 -HUP -f '^/usr/sbin/nagios'",
      }

      exec {'create fifo':
        command => 'mknod -m 0664 /var/run/nagios/rw/nagios.cmd p && chown nagios /var/run/nagios/rw/nagios.cmd',
        unless  => 'test -p /var/run/nagios/rw/nagios.cmd',
        require => File['nagios read-write dir'],
      }
    }

    '7': {
      selinux::fcontext{ '/var/cache/nagios':
        setype => 'nagios_log_t',
      }

      Service['nagios'] {
        provider => 'systemd',
      }

      Exec['nagios-restart'] {
        command => "nagios -v ${nagios::params::conffile} && systemctl restart nagios.service",
      }

      Exec['nagios-reload'] {
        command => "nagios -v ${nagios::params::conffile} && systemctl reload nagios.service",
      }

    }

    default: {
      fail "nagios::redhat doesn't support ${::operatingsystemmajrelease} yet"
    }

  }
}
