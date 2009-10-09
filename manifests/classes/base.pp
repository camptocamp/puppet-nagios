#
# modules/nagios/manifests/classes/base.pp
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

class nagios::base {
  include nagios::os

  file {"/var/lib/nagios3":
    ensure  => directory,
    owner   => nagios,
    group   => nagios,
    mode    => 751,
    require => [Class["nagios::os"], Package["nagios"]],
  }

  file {[$nagios_cfg_dir, $nagios_root_dir, "$nagios_root_dir/nagios.d"]:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => 755,
    require => Class["nagios::os"],
  }

  file {"$nagios_root_dir/conf.d":
    ensure => absent,
    force => true,
    require => Class["nagios::os"],
  }

  file {$nagios_main_config_file:
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    require => Class["nagios::os"],
  }

  file {"$nagios_cfg_dir/generic-host.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///nagios/generic-host.cfg",
    require => [Class["nagios::os"], File[$nagios_cfg_dir]],
    notify  => Exec["nagios-reload"],
  }

  case $operatingsystem {
    Debian: { $nagios_mail_path = '/usr/bin/mail' }

    Redhat: { $nagios_mail_path = '/bin/mail' }

    default: { err ("operatingsystem $operatingsystem not yet implemented !") }
  }

  file {"$nagios_cfg_dir/generic-command.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("nagios/generic-command.cfg.erb"),
    require => [Class["nagios::os"], File[$nagios_cfg_dir]],
    notify  => Exec["nagios-reload"],
  }

  file {"$nagios_cfg_dir/generic-timeperiod.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///nagios/generic-timeperiod.cfg",
    require => [Class["nagios::os"], File[$nagios_cfg_dir]],
    notify  => Exec["nagios-reload"],
  }

  file {"$nagios_cfg_dir/generic-service.cfg":
    ensure  => present,
  }

  # default objects files
  file {[
      "$nagios_cfg_dir/hosts.cfg",
      "$nagios_cfg_dir/services.cfg",
      "$nagios_cfg_dir/contacts.cfg",
      "$nagios_cfg_dir/commands.cfg",
      "$nagios_cfg_dir/contactgroups.cfg",
      "$nagios_cfg_dir/hostgroups.cfg",
    ]:
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    require => File[$nagios_cfg_dir],
  }

  nagios_contact {"root":
    contact_name                  => "root",
    alias                         => "Root",
    service_notification_period   => "24x7",
    host_notification_period      => "24x7",
    service_notification_options  => "w,u,c,r",
    host_notification_options     => "d,r",
    service_notification_commands => "notify-service-by-email",
    host_notification_commands    => "notify-host-by-email",
    email                         => "root",
    target                        => "$nagios_cfg_dir/contacts.cfg",
    notify                        => Exec["nagios-reload"],
    require                       => File["$nagios_cfg_dir/contacts.cfg"],
  }

  nagios_contactgroup {"admins":
    contactgroup_name => "admins",
    alias             => "Nagios Administrators",
    members           => "root",
    target            => "$nagios_cfg_dir/contactgroups.cfg",
    notify            => Exec["nagios-reload"],
    require           => [Nagios_Contact["root"], File["$nagios_cfg_dir/contactgroups.cfg"]],
  }
}
