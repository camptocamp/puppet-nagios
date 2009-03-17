#
# modules/nagios/manifests/classes/webinterface.pp
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

class nagios::webinterface {
  
  file {"$nagios_root_dir/cgi.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("nagios/cgi.cfg.erb"),
    require => Package["nagios3-common"],
    notify  => Exec["apache-graceful"],
  }

  file {"/etc/apache2/conf.d/nagios3.conf":
    ensure  => absent,
    notify  => Exec["apache-graceful"],
  }

}
