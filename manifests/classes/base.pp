#
# modules/nagios/manifests/classes/base.pp
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

class nagios::base {
  case $operatingsystem {
    Debian: {
      case $lsbdistcodename {
        etch: {
         
          os::backported_package {[
              "nagios3",
              "nagios3-common",
              "nagios-plugins",
              "nagios-plugins-standard",
              "nagios-plugins-basic",
            ]:
            ensure => installed,
          }
        }

        lenny,squeeze: {
          apt::preferences {[
            "nagios3",
            "nagios3-doc",
            "nagios3-cgi",
            "nagios3-common",
            "nagios-plugins",
            "nagios-plugins-standard",
            "nagios-plugins-basic"
            ]:
            pin => "release a=${lsbdistcodename}-backports",
            priority => "1100";
          }

          package {[
            "nagios3",
            "nagios3-doc",
            "nagios3-cgi",
            "nagios3-common",
            "nagios-plugins",
            "nagios-plugins-standard",
            "nagios-plugins-basic",
            ]:
            ensure => installed,
          }
        }
        default: {err ("lsbdistcodename $lsbdistcodename not yet implemented !")} 
      }
    }
    default: {err ("operatingsystem $operatingsystem not yet implemented !")}
  }

  file {"/etc/default/nagios3":
    ensure => present,
    owner => root,
    group => root,
    mode => 644,
    content => template("nagios/etc/default/nagios3.erb"),
    notify => [ Package["nagios3"], Exec["nagios3-restart"] ],
  }

  file {"/var/lib/nagios3":
    ensure  => directory,
    owner   => nagios,
    group   => nagios,
    mode    => 751,
    require => Package["nagios3-common"],
  }

  file {"/var/lib/nagios3/rw":
    ensure  => directory,
    owner   => nagios,
    group   => www-data,
    mode    => 2710,
    require => Package["nagios3-common"],
  }

  service {"nagios3":
    ensure      => running,
    hasrestart  => true,
    require     => Package["nagios3"],
  }

  exec {"nagios3-restart":
    command => "/etc/init.d/nagios3 restart",
    refreshonly => true,
    onlyif => "/usr/sbin/nagios3 -v $nagios_main_config_file |/bin/grep -q 'Things look okay'",
  }

  exec {"nagios-reload":
    command     => "/etc/init.d/nagios3 reload",
    refreshonly => true,
    onlyif      => "/usr/sbin/nagios3 -v $nagios_main_config_file |/bin/grep -q 'Things look okay'",
  }

  file {[$nagios_cfg_dir, $nagios_root_dir, "$nagios_root_dir/nagios.d"]:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => 755,
    require => [Package["nagios3"], Package["nagios3-common"]],
  }

  file {"$nagios_root_dir/conf.d":
    ensure => absent,
    force => true,
    recurse => true,
    purge => true,
    require => [Package["nagios3"], Package["nagios3-common"]],
  }

  file {$nagios_main_config_file:
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    require => Package["nagios3-common"],
  }

  file {"/etc/apache2/conf.d/nagios3.conf":
    ensure => absent,
    notify  => Exec["nagios-reload"],
  }

  common::concatfilepart {"main":
    file    => $nagios_main_config_file,
    content => template("nagios/nagios.cfg.erb"),
    notify  => Exec["nagios-reload"],
  }

  file {"$nagios_cfg_dir/generic-host.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///nagios/generic-host.cfg",
    require => [Package["nagios3-common"], File[$nagios_cfg_dir]],
    notify  => Exec["nagios-reload"],
  }

  file {"$nagios_cfg_dir/generic-service.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///nagios/generic-service.cfg",
    require => [Package["nagios3-common"], File[$nagios_cfg_dir]],
    notify  => Exec["nagios-reload"],
  }
 
  file {"$nagios_cfg_dir/generic-contact.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///nagios/generic-contact.cfg",
    require => [Package["nagios3-common"], File[$nagios_cfg_dir]],
    notify  => Exec["nagios-reload"],
  }

  file {"$nagios_cfg_dir/generic-command.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///nagios/generic-command.cfg",
    require => [Package["nagios3-common"], File[$nagios_cfg_dir]],
    notify  => Exec["nagios-reload"],
  }

  file {"$nagios_cfg_dir/generic-timeperiod.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///nagios/generic-timeperiod.cfg",
    require => [Package["nagios3-common"], File[$nagios_cfg_dir]],
    notify  => Exec["nagios-reload"],
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
