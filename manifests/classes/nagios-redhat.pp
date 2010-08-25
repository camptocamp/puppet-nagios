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
    seltype => "nagios_log_t",
  }

  /* redhat specific resources below */

  file {"/etc/default/nagios": ensure => absent }

  file {"/etc/nagios3": ensure => absent }

  if $lsbmajdistrelease == 5 and $operatingsystem == 'RedHat' {
    File["/var/run/nagios",
         "/var/log/nagios",
         "/var/lib/nagios",
         "/var/lib/nagios/spool",
         "/var/lib/nagios/spool/checkresults",
         "/var/cache/nagios"] {
      seltype => "nagios_log_t",
    }

    exec { "chcon /var/lib/nagios/rw/nagios.cmd":
      require => Exec["create node"],
      command => "chcon -t nagios_spool_t /var/lib/nagios/rw/nagios.cmd",
      unless  => "ls -Z /var/lib/nagios/rw/nagios.cmd | grep -q nagios_spool_t",
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

  exec {"create node":
    command => "mknod -m 0664 /var/lib/nagios/rw/nagios.cmd p && chown nagios:${group} /var/lib/nagios/rw/nagios.cmd",
    unless  => "test -p /var/lib/nagios/rw/nagios.cmd",
    require => File["nagios read-write dir"],
  }
}
