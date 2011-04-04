/*
== Definition: nagios::resource

Add macros to nagios's resource.cfg configuration file.

Example:

  nagios::resource { "USER1":
    value => "/usr/lib/nagios/plugins",
  }

Further reading:
http://nagios.sourceforge.net/docs/3_0/configmain.html#resource_file

*/
define nagios::resource ($ensure="present", $value) {

  include nagios::params

  common::concatfilepart { $name:
    ensure  => $ensure,
    file    => "${nagios::params::rootdir}/resource.cfg",
    content => "\$${name}\$=\"${value}\"\n",
    notify  => Exec["nagios-restart"],
    require => Package["nagios"],
  }
}
