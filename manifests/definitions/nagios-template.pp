/*
== Definition: nagios::template

Simple wrapper around a file resource, to ease nagios template creation.

Example:

  nagios::template {"generic-service-active":
    conf_type => "service",
    content   => "
      use                     generic-service
      active_checks_enabled   1
      register                0",
  }

*/
define nagios::template($ensure=present, $content, $conf_type) {

  include nagios::params

  # set rights and owner
  file {"${nagios::params::resourcedir}/${conf_type}-${name}.cfg":
    ensure => $ensure,
    owner  => root,
    group  => root,
    mode   => 0644,
    content => template("nagios/template-all.erb"),
    notify  => Exec["nagios-restart"],
  }
}
