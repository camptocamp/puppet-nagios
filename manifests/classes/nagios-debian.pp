class nagios::debian inherits nagios::base {

  include nagios::params

  /* Common resources between base, redhat, and debian */

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

  Service["nagios"] {
    name => "nagios3",
  }

  Exec["nagios-restart"] {
    command => "nagios3 -v ${nagios::params::conffile} && /etc/init.d/nagios3 restart",
  }

  Exec["nagios-reload"] {
    command => "nagios3 -v ${nagios::params::conffile} && /etc/init.d/nagios3 reload",
  }

  File["nagios read-write dir"] {
    group => "www-data",
    mode  => 2710,
  }

  File["/var/lib/nagios3"] {
    mode => 751,
  }


  /* debian specific resources below */

  file {"/etc/default/nagios3":
    ensure => present,
    owner => root,
    group => root,
    mode => 644,
    content => template("nagios/etc/default/nagios3.erb"),
    require => Package["nagios3"],
  }

}
