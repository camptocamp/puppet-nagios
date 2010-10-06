/*
== Class: nagios::redhat

Define common resources specific to redhat based systems. It shouldn't be
necessary to include this class directly. Instead, you should use:

  include nagios

*/
class nagios::redhat inherits nagios::base {

  include nagios::params

  /* Common resources between base, redhat, and debian */

  package { "nagios":
    ensure => present,
  }

  Service["nagios"] {
    hasstatus   => false,
    pattern     => "/usr/sbin/nagios -d /etc/nagios/nagios.cfg",
  }

  #TODO: make this reliable:
  if defined( Class["apache"] ) {
    $group = "apache"
  } else {
    $group = "nagios"
  }

  File["nagios read-write dir"] {
    group   => $group,
    mode    => 0755,
  }

  /* redhat specific resources below */

  file {"/etc/default/nagios": ensure => absent }

  file {"/etc/nagios3": ensure => absent }

  case $lsbmajdistrelease {

    5: {
      File["/var/run/nagios",
           "/var/log/nagios",
           "/var/lib/nagios",
           "/var/lib/nagios/spool",
           "/var/lib/nagios/spool/checkresults",
           "/var/cache/nagios"] {
        seltype => "nagios_log_t",
      }

      File["nagios read-write dir"] {
        seltype => "nagios_log_t",
      }

      exec { "chcon /var/run/nagios/rw/nagios.cmd":
        require => [Exec["create node"], File["nagios read-write dir"]],
        command => "chcon -t nagios_spool_t /var/run/nagios/rw/nagios.cmd",
        unless  => "ls -Z /var/run/nagios/rw/nagios.cmd | grep -q nagios_spool_t",
        onlyif  => $selinux,
      }

      file {["/var/lib/nagios/retention.dat",
             "/var/cache/nagios/nagios.tmp",
             "/var/cache/nagios/status.dat",
             "/var/cache/nagios/objects.precache",
             "/var/cache/nagios/objects.cache"]:
        ensure  => present,
        seltype => "nagios_log_t",
        owner   => nagios,
        group   => nagios,
        require => File["/var/run/nagios"],
      }
      File["/var/lib/nagios/retention.dat"] { mode => 0600 }
      File["/var/cache/nagios/status.dat"]  { mode => 0664 }
    }

  }

  # workaround broken init-script
  Exec["nagios-restart"] {
    command => "nagios -v ${nagios::params::conffile} && pkill -P 1 -f '^/usr/sbin/nagios' && /etc/init.d/nagios start",
  }

  Exec["nagios-reload"] {
    command => "nagios -v ${nagios::params::conffile} && pkill -HUP -f '^/usr/sbin/nagios'",
  }

  exec {"create node":
    command => "mknod -m 0664 /var/run/nagios/rw/nagios.cmd p && chown nagios:${group} /var/run/nagios/rw/nagios.cmd",
    unless  => "test -p /var/run/nagios/rw/nagios.cmd",
    require => File["nagios read-write dir"],
  }
}
