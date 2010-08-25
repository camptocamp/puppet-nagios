define nagios::template($ensure=present, $content, $conf_type) {

  include nagios::params

  # set rights and owner
  file {"${nagios::params::resourcedir}/${conf_type}-${name}.cfg":
    ensure => $ensure,
    owner  => root,
    group  => root,
    mode   => 0644,
    content => template("nagios/template-all.erb"),
    notify  => Exec["nagios-reload"],
  }
}
