#
# modules/nagios/manifests/classes/webinterface.pp
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

class nagios::webinterface {

  case $operatingsystem {

    RedHat: {
      $nagios_main_config_file = "/etc/nagios/nagios.cfg"
      $nagios_physical_html_path = "/usr/share/nagios"
      $nagios_url_html_path = "/nagios"
      $nagios_nagios_check_command = "/usr/lib64/nagios/plugins/check_nagios /var/cache/nagios3/status.dat 5 '/usr/sbin/nagios'"

      package {["nagios-www", "php", "nagios-plugins-nagios"]:
        ensure => present,
      }

      file {"/etc/httpd/conf.d/nagios3.conf":
        ensure  => absent,
        require => Package["nagios-www"],
        notify  => Exec["apache-graceful"],
      }

      file {"$nagios_root_dir/cgi.cfg":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        content => template("nagios/cgi.cfg.erb"),
        require => Class["nagios::os"],
        notify  => Exec["apache-graceful"],
      }

      #SELinux - see 
      # http://grokbase.com/post/2008/12/06/centos-trying-to-setting-a-selinux-policy-to-nagios-3-0-6-on-centos-5-2/u-x2GXaK02ZlLVNVs_Mkq0G2hDg
      selinux::module {"nagios-httpd":
        content => "
module nagios-httpd 1.1;
require {
  type var_t;
  type httpd_t;
  type nagios_log_t;
  type httpd_nagios_script_t;
  class fifo_file { write getattr read create };
  class file { rename setattr read create write getattr unlink };
}
#============= httpd_nagios_script_t ==============
allow httpd_nagios_script_t var_t:fifo_file { write getattr };
allow httpd_nagios_script_t var_t:file { read getattr };
#============= httpd_t ==============
allow httpd_t nagios_log_t:file read;
",
        notify  => Selmodule["nagios-httpd"],
      }
      selmodule {"nagios-httpd":
        ensure => present,
        syncversion => true,
        require => Selinux::Module["nagios-httpd"],
      }
    }

    Debian: {
      file {"$nagios_root_dir/cgi.cfg":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        content => template("nagios/cgi.cfg.erb"),
        require => Class["nagios::os"],
        notify  => Exec["apache-graceful"],
      }

      file {"/etc/apache2/conf.d/nagios3.conf":
        ensure  => absent,
        notify  => Exec["apache-graceful"],
      }
    }
    default: { notice "nothing more to do" }
  }

}
