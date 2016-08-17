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

  # redhat specific resources below

  file {'/etc/default/nagios': ensure => absent }

  file {'/etc/nagios3': ensure => absent }

  case $::operatingsystemmajrelease {

    '5','6': {
      File[
        '/var/log/nagios',
        '/var/lib/nagios',
        '/var/lib/nagios/spool',
        '/var/lib/nagios/spool/checkresults',
        '/var/cache/nagios'
        ] {
        seltype => 'nagios_log_t',
      }

      Service['nagios'] {
        hasstatus   => false,
        pattern     => '/usr/sbin/nagios -d /etc/nagios/nagios.cfg',
      }

      # workaround broken init-script
      Exec['nagios-restart'] {
        command => "nagios -v ${nagios::params::conffile} && pkill -P 1 -f '^/usr/sbin/nagios' && /etc/init.d/nagios start",
      }

      Exec['nagios-reload'] {
        command => "nagios -v ${nagios::params::conffile} && pkill -P 1 -HUP -f '^/usr/sbin/nagios'",
      }
    }

    '7': {
      Service['nagios'] {
        provider => 'redhat',
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
