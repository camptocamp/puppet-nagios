#
# modules/nagios/manifests/definitions/host-local.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::local::hostgroup ($ensure=present) {

  nagios_hostgroup { $name:
    ensure  => $ensure,
    target  => "$nagios_cfg_dir/hostgroups.cfg",
    notify  => Exec["nagios-reload"],
    require => [
      Class["nagios::base"],
      File["nagios_hostgroups.cfg"],
    ],
  }

}
