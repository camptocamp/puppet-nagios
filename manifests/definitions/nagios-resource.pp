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

  common::concatfilepart { $name:
    ensure  => $ensure,
    file    => "$nagios_root_dir/resource.cfg",
    content => "\$${name}\$=\"${value}\"\n",
    notify  => Exec["nagios-reload"],
    require => Package["nagios3"],
  }
}
