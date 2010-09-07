/*
== Class: nagios::webinterface

This class takes care of all the bits needed to run the CGIs used to display
nagios's status in a web browser.

Example usage:
  include nagios
  include nagios::webinterface

*/
class nagios::webinterface {

  include nagios::params

  # variables used in erb template.
  $nagios_main_config_file     = "${nagios::params::conffile}"
  $nagios_physical_html_path   = "/usr/share/${nagios::params::basename}"
  $nagios_url_html_path        = "/${nagios::params::basename}"
  $nagios_nagios_check_command = "${nagios::params::user1}/check_nagios /var/cache/${nagios::params::basename}/status.dat 5 '/usr/sbin/${nagios::params::basename}'"

  file {"${nagios::params::rootdir}/cgi.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("nagios/cgi.cfg.erb"),
    require => Class["nagios"],
    notify  => Exec["apache-graceful"],
  }

  case $operatingsystem {

    /RedHat|CentOS|Fedora/: {
      package {["nagios-www", "nagios-plugins-nagios"]:
        ensure => present,
      }

      file {"/etc/httpd/conf.d/nagios3.conf":
        ensure  => absent,
        require => Package["nagios-www"],
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

    /Debian|Ubuntu/: {
      file {"/etc/apache2/conf.d/nagios3.conf":
        ensure  => absent,
        notify  => Exec["apache-graceful"],
      }
    }
  }

}
