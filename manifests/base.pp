# == Class: nagios::base
#
# Define common resources between debian and redhat based systems. It shouldn't
# be necessary to include this class directly. Instead, you should use:
#
#   include nagios
#
class nagios::base {
  assert_private()

  include ::nagios::params

  # variables used in ERB template
  $basename = $nagios::params::basename
  $nagios_p1_file = $nagios::params::p1file
  $nagios_debug_level = '0'
  $nagios_debug_verbosity = '0'
  $pidfile = $nagios::params::pidfile

  case $::osfamily {
    'Debian': { $nagios_mail_path = '/usr/bin/mail' }
    'RedHat': { $nagios_mail_path = '/bin/mail' }
    default: { fail ("OS family ${::osfamily} not yet implemented !") }
  }

  # Common resources between base, redhat, and debian

  user { 'nagios':
    ensure  => $nagios::ensure,
    shell   => '/bin/sh',
    require => Package['nagios'],
  }

  $svc_ensure = $nagios::ensure ? {
    present => running,
    default => stopped,
  }

  service { 'nagios':
    ensure     => $svc_ensure,
    enable     => true,
    hasrestart => true,
    require    => Package['nagios'],
  }

  exec { 'nagios-restart':
    command     => "${nagios::params::basename} -v ${nagios::params::conffile} && /etc/init.d/${nagios::params::basename} restart",
    refreshonly => true,
    path        => $::path,
  }

  exec { 'nagios-reload':
    command     => "${nagios::params::basename} -v ${nagios::params::conffile} && /etc/init.d/${nagios::params::basename} reload",
    refreshonly => true,
    path        => $::path,
  }

  $read_write_dir = $::osfamily ? {
    'Debian' => '/var/lib/nagios3/rw',
    'RedHat' => '/var/spool/nagios/cmd',
  }
  $command_file = "${read_write_dir}/nagios.cmd"

  $file_ensure = $nagios::ensure ? {
    present => file,
    default => absent,
  }

  $dir_ensure = $nagios::ensure ? {
    present => directory,
    default => absent,
  }

  file { 'nagios read-write dir':
    ensure  => $dir_ensure,
    path    => $read_write_dir,
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '2710',
    require => Package['nagios'],
  }

  file { 'nagios query-handler read-write dir':
    ensure  => $dir_ensure,
    path    => "/var/log/${nagios::params::basename}/rw",
    owner   => 'nagios',
    group   => 'nagios',
    mode    => '2710',
    require => Package['nagios'],
  }

  file {[
    "/var/run/${nagios::params::basename}",
    "/var/log/${nagios::params::basename}",
    "/var/lib/${nagios::params::basename}",
    "/var/lib/${nagios::params::basename}/spool",
    "/var/lib/${nagios::params::basename}/spool/checkresults",
    "/var/cache/${nagios::params::basename}",
  ]:
    ensure  => $dir_ensure,
    owner   => nagios,
    group   => nagios,
    mode    => '0755',
    require => Package['nagios'],
    before  => Service['nagios'],
  }

  nagios::resource { 'USER1': value => $nagios::params::user1 }

  concat {[
      $nagios::params::conffile,
      "${nagios::params::rootdir}/resource.cfg",
    ]:
    ensure => $nagios::ensure,
    notify  => Exec['nagios-restart'],
    require => Package['nagios'],
  }

  $use_syslog = $nagios::use_syslog
  concat::fragment {'main':
    target  => $nagios::params::conffile,
    content => template('nagios/nagios.cfg.erb'),
  }

  # other common resources below

  file { ["${nagios::params::rootdir}/conf.d",
          "${nagios::params::rootdir}/auto-puppet",
          "${nagios::params::rootdir}/nagios.d"]:
    ensure  => absent,
    force   => true,
    recurse => true,
    require => Package['nagios'],
  }

  # purge undefined nagios resources
  file { $nagios::params::resourcedir:
    ensure  => directory,
    # lint:ignore:fileserver
    source  => 'puppet:///modules/nagios/empty',
    # lint:endignore
    owner   => root,
    group   => root,
    mode    => '0644',
    purge   => true,
    force   => true,
    recurse => true,
    notify  => Exec['nagios-restart'],
  }

  $module_path = get_module_path($module_name)
  file {"${nagios::params::resourcedir}/generic-host.cfg":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => file("${module_path}/files/generic-host.cfg"),
    notify  => Exec['nagios-restart'],
  }

  $check_ping_ipv = $::nagios::check_ping_ipv
  file {"${nagios::params::resourcedir}/generic-command.cfg":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('nagios/generic-command.cfg.erb'),
    notify  => Exec['nagios-restart'],
  }

  file {"${nagios::params::resourcedir}/generic-timeperiod.cfg":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => file("${module_path}/files/generic-timeperiod.cfg"),
    notify  => Exec['nagios-restart'],
  }

  file {"${nagios::params::resourcedir}/base-contacts.cfg":
    ensure => $file_ensure,
    owner  => 'root',
    mode   => '0644',
  }

  nagios_contact { 'root':
    ensure                        => $nagios::ensure,
    contact_name                  => 'root',
    # lint:ignore:alias_parameter
    alias                         => 'Root',
    # lint:endignore
    service_notification_period   => '24x7',
    host_notification_period      => '24x7',
    service_notification_options  => 'w,u,c,r',
    host_notification_options     => 'd,r',
    service_notification_commands => 'notify-service-by-email',
    host_notification_commands    => 'notify-host-by-email',
    email                         => 'root',
    target                        => "${nagios::params::resourcedir}/base-contacts.cfg",
    notify                        => Exec['nagios-restart'],
    require                       => File["${nagios::params::resourcedir}/base-contacts.cfg"],
  }

  file {"${nagios::params::resourcedir}/base-contactgroups.cfg":
    ensure => $file_ensure,
    owner  => 'root',
    mode   => '0644',
  }

  nagios_contactgroup { 'admins':
    ensure            => $nagios::ensure,
    contactgroup_name => 'admins',
    # lint:ignore:alias_parameter
    alias             => 'Nagios Administrators',
    # lint:endignore
    members           => 'root',
    target            => "${nagios::params::resourcedir}/base-contactgroups.cfg",
    notify            => Exec['nagios-restart'],
    require           => [
      Nagios_contact['root'],
      File["${nagios::params::resourcedir}/base-contactgroups.cfg"]
    ],
  }

  file {"${nagios::params::resourcedir}/base-servicegroup.cfg":
    ensure => $file_ensure,
    owner  => 'root',
    mode   => '0644',
  }

  nagios_servicegroup { 'default':
    ensure  => $nagios::ensure,
    # lint:ignore:alias_parameter
    alias   => 'Default Service Group',
    # lint:endignore
    target  => "${nagios::params::resourcedir}/base-servicegroup.cfg",
    notify  => Exec['nagios-restart'],
    require => File["${nagios::params::resourcedir}/base-servicegroup.cfg"],
  }

}
