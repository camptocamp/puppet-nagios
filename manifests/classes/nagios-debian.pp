class nagios::debian {
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
    
    lenny: {
      package {[
        "nagios3",
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

  file {"/etc/default/nagios3":
    ensure => present,
    owner => root,
    group => root,
    mode => 644,
    content => template("nagios/etc/default/nagios3.erb"),
    notify => [ Package["nagios3-common"], Exec["nagios-restart"] ],
  }

  service {"nagios3":
    ensure      => running,
    hasrestart  => true,
    require     => Class["nagios::packages"],
    alias       => "nagios",
  }

  exec {"nagios-restart":
    command => "/etc/init.d/nagios3 restart",
    refreshonly => true,
    onlyif => "/usr/sbin/nagios3 -v $nagios_main_config_file |/bin/grep -q 'Things look okay'",
  }

  exec {"nagios-reload":
    command     => "/etc/init.d/nagios3 reload",
    refreshonly => true,
    onlyif      => "/usr/sbin/nagios3 -v $nagios_main_config_file |/bin/grep -q 'Things look okay'",
  }

  file {"/var/lib/nagios3/rw":
    ensure  => directory,
    owner   => nagios,
    group   => www-data,
    mode    => 2710,
  }

  common::concatfilepart {"main":
    file    => $nagios_main_config_file,
    content => template("nagios/nagios.cfg.erb"),
    notify  => Exec["nagios-reload"],
  }
}
