class nagios::debian inherits nagios::base {

  case $lsbdistcodename {
    etch: {
      
      os::backported_package {[
          "nagios3-common",
          "nagios-plugins",
          "nagios-plugins-standard",
          "nagios-plugins-basic",
        ]:
        ensure => installed,
      }
      os::backported_package {"nagios3":
        ensure => installed,
        alias  => "nagios",
      }
    }
    
    lenny: {
      package {[
        "nagios3-common",
        "nagios-plugins",
        "nagios-plugins-standard",
        "nagios-plugins-basic",
        ]:
        ensure => installed,
      }
      package {"nagios3":
        ensure => installed,
        alias  => "nagios",
      }
    }
    default: {err ("lsbdistcodename $lsbdistcodename not yet implemented !")}
  }

  file {"/etc/default/nagios3":
    ensure => present,
    owner => root,
    group => root,
    mode => 644,
    content => template("nagios/etc/default/nagios3.erb"),
    require => Package["nagios3"],
  }

  service {"nagios3":
    ensure      => running,
    hasrestart  => true,
    require     => Package["nagios3"],
    alias       => "nagios",
  }

  exec {"nagios-restart":
    command => "/usr/sbin/nagios3 -v ${nagios_main_config_file} && /etc/init.d/nagios3 restart",
    refreshonly => true,
  }

  exec {"nagios-reload":
    command     => "/usr/sbin/nagios3 -v ${nagios_main_config_file} && /etc/init.d/nagios3 reload",
    refreshonly => true,
  }

  file {"/var/lib/nagios3":
    ensure  => directory,
    owner   => nagios,
    group   => nagios,
    mode    => 751,
  }


  file {"/var/lib/nagios3/rw":
    ensure  => directory,
    owner   => nagios,
    group   => www-data,
    mode    => 2710,
    require => File["/var/lib/nagios3"],
  }

  common::concatfilepart {"main":
    file    => $nagios_main_config_file,
    content => template("nagios/nagios.cfg.erb"),
    before  => Service["nagios"],
    require => Package["nagios3"],
  }

  file {"${nagios_root_dir}/resource.cfg":
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
  }

  nagios::resource { "USER1": value => "/usr/lib/nagios/plugins" }

}
