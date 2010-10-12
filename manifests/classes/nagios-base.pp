/*
== Class: nagios::base

Define common resources between debian and redhat based systems. It shouldn't
be necessary to include this class directly. Instead, you should use:

  include nagios

*/
class nagios::base {

  include nagios::params

  # variables used in ERB template
  $basename = "${nagios::params::basename}"
  $nagios_p1_file = "${nagios::params::p1file}"
  $nagios_debug_level = "0"
  $nagios_debug_verbosity = "0"

  case $operatingsystem {
    /Debian|Ubuntu/ : { $nagios_mail_path = '/usr/bin/mail' }
    /RedHat|CentOS|Fedora/ : { $nagios_mail_path = '/bin/mail' }
    default: { err ("operatingsystem $operatingsystem not yet implemented !") }
  }

  /* Common resources between base, redhat, and debian */

  service { "nagios":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package["nagios"],
  }

  exec { "nagios-restart":
    command     => "${nagios::params::basename} -v ${nagios::params::conffile} && /etc/init.d/${nagios::params::basename} restart",
    refreshonly => true,
  }

  exec { "nagios-reload":
    command     => "${nagios::params::basename} -v ${nagios::params::conffile} && /etc/init.d/${nagios::params::basename} reload",
    refreshonly => true,
  }

  file { "nagios read-write dir":
    ensure  => directory,
    path    => "/var/run/${nagios::params::basename}/rw",
    owner   => "nagios",
    group   => "nagios",
    mode    => 2710,
    require => Package["nagios"],
  }

  file {["/var/run/${nagios::params::basename}",
         "/var/log/${nagios::params::basename}",
         "/var/lib/${nagios::params::basename}",
         "/var/lib/${nagios::params::basename}/spool",
         "/var/lib/${nagios::params::basename}/spool/checkresults",
         "/var/cache/${nagios::params::basename}"]:
    ensure  => directory,
    owner   => nagios,
    group   => nagios,
    mode    => 0755,
    require => Package["nagios"],
    before  => Service["nagios"],
  }


  file {"${nagios::params::rootdir}/resource.cfg":
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
  }

  nagios::resource { "USER1": value => "${nagios::params::user1}" }

  common::concatfilepart {"main":
    file    => "${nagios::params::conffile}",
    content => template("nagios/nagios.cfg.erb"),
    notify  => Exec["nagios-restart"],
    require => Package["nagios"],
  }


  /* other common resources below */

  file { ["${nagios::params::rootdir}/conf.d",
          "${nagios::params::rootdir}/auto-puppet",
          "${nagios::params::rootdir}/nagios.d"]:
    ensure  => absent,
    force   => true,
    recurse => true,
    require => Package["nagios"],
  }

  # purge undefined nagios resources
  file { "${nagios::params::resourcedir}":
    ensure  => directory,
    source  => "puppet:///nagios/empty",
    owner   => root,
    group   => root,
    mode    => 644,
    purge   => true,
    force   => true,
    recurse => true,
    notify  => Exec["nagios-restart"],
  }

  file { "${nagios::params::conffile}":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    require => Package["nagios"],
  }

  file {"${nagios::params::resourcedir}/generic-host.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///nagios/generic-host.cfg",
    notify  => Exec["nagios-restart"],
  }

  file {"${nagios::params::resourcedir}/generic-command.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("nagios/generic-command.cfg.erb"),
    notify  => Exec["nagios-restart"],
  }

  file {"${nagios::params::resourcedir}/generic-timeperiod.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///nagios/generic-timeperiod.cfg",
    notify  => Exec["nagios-restart"],
  }

  file {"${nagios::params::resourcedir}/base-contacts.cfg":
    ensure => present,
    owner  => "root",
    mode   => 0644,
  }

  nagios_contact { "root":
    contact_name                  => "root",
    alias                         => "Root",
    service_notification_period   => "24x7",
    host_notification_period      => "24x7",
    service_notification_options  => "w,u,c,r",
    host_notification_options     => "d,r",
    service_notification_commands => "notify-service-by-email",
    host_notification_commands    => "notify-host-by-email",
    email                         => "root",
    target                        => "${nagios::params::resourcedir}/base-contacts.cfg",
    notify                        => Exec["nagios-restart"],
    require                       => File["${nagios::params::resourcedir}/base-contacts.cfg"],
  }

  file {"${nagios::params::resourcedir}/base-contactgroups.cfg":
    ensure => present,
    owner  => "root",
    mode   => 0644,
  }

  nagios_contactgroup { "admins":
    contactgroup_name => "admins",
    alias             => "Nagios Administrators",
    members           => "root",
    target            => "${nagios::params::resourcedir}/base-contactgroups.cfg",
    notify            => Exec["nagios-restart"],
    require           => [
      Nagios_contact["root"],
      File["${nagios::params::resourcedir}/base-contactgroups.cfg"]
    ],
  }

  file {"${nagios::params::resourcedir}/base-servicegroup.cfg":
    ensure => present,
    owner  => "root",
    mode   => 0644,
  }

  nagios_servicegroup { "default":
    alias             => "Default Service Group",
    target            => "${nagios::params::resourcedir}/base-servicegroup.cfg",
    notify            => Exec["nagios-restart"],
    require           => File["${nagios::params::resourcedir}/base-servicegroup.cfg"],
  }

}
