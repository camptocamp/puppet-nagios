#
# modules/nagios/manifests/definitions/host-local.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::hostgroup::local ($ensure=present, $nagios_alias) {

  nagios_hostgroup {$name:
    ensure => $ensure,
    alias => $nagios_alias,
    target => "$nagios_cfg_dir/hostgroups.cfg",
    notify => Exec["nagios-reload"],
    require => File["$nagios_cfg_dir/hostgroups.cfg"],
  }

}
