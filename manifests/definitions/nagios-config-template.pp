define nagios::config::template($ensure=present, $content, $conf_type) {

  # set rights and owner
  file {"${nagios_cfg_dir}/${conf_type}-${name}.cfg":
    ensure => $ensure,
    owner  => root,
    group  => root,
    mode   => 0644,
    content => template("nagios/template-all.erb"),
    notify  => Exec["nagios-reload"],
  }
}
