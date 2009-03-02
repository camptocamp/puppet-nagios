#
# modules/nagios/manifests/classes/webinterface.pp
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

class nagios::webinterface {
  if defined (Apache::Vhost[$fqdn]) {
     notice "Apache Virtual Host $fqdf already defined"
   } else {
     apache::vhost {$fqdn:
       ensure => present,
     }
   }

   file {"/var/www/$fqdn/private/nagios-htpasswd":
     ensure  => present,
     owner   => root,
     group   => root,
     mode    => 644,
     require => Apache::Vhost[$fqdn],
   }

   if $nagiosadmin_password {
     # superadmin access
     line {"nagiosadmin password":
       line    => "nagiosadmin:${nagiosadmin_password}",
       ensure  => present,
       file    => "/var/www/$fqdn/private/nagios-htpasswd",
       require => File["/var/www/$fqdn/private/nagios-htpasswd"],
     }
   }

   file {"/var/www/$fqdn/conf/nagios.conf":
     ensure  => present,
     owner   => root,
     group   => root,
     mode    => 644,
     content => template("nagios/apache.conf.erb"),
     require => File["/var/www/$fqdn/private/nagios-htpasswd"],
     notify  => Exec["apache2-graceful"],
   }

   file {"$nagios_root_dir/cgi.cfg":
     ensure  => present,
     owner   => root,
     group   => root,
     mode    => 644,
     content => template("nagios/cgi.cfg.erb"),
     require => Package["nagios3-common"],
     notify  => Exec["apache2-graceful"],
   }
}
