class nagios::redhat {

  $nagios_log_file = "/var/log/nagios/nagios.log"
  $nagios_lock_file = "/var/run/nagios.pid"
  $nagios_debug_level = "0"
  $nagios_debug_verbosity = "0"
  $nagios_debug_file = "/var/log/nagios/nagios.debug"
  $nagios_state_retention_file = "/var/log/nagios/retention.dat"
  $nagios_p1_file = "/usr/sbin/p1.pl"
  $nagios_log_archive_path ="/var/log/nagios/archives"
  $nagios_temp_file = "/var/log/nagios/nagios.tmp"
  $nagios_command_file = "/var/log/nagios/rw/nagios.cmd"
  $nagios_status_file = "/var/log/nagios/status.dat"
  $nagios_precached_object_file = "/var/log/nagios/objects.precache"
  $nagios_object_cache_file = "/var/log/nagios/objects.cache"

  package {"nagios":
    ensure => present,
    alias  => "nagios3",
  }

  service {"nagios":
    ensure      => running,
    enable      => true,
    hasstatus   => false,
    hasrestart  => true,
    require     => Package["nagios"],
    pattern     => "/usr/sbin/nagios -d /etc/nagios/nagios.cfg",
  }

  exec {"nagios-restart":
    command => "/etc/init.d/nagios restart",
    refreshonly => true,
    onlyif => "/usr/sbin/nagios -v $nagios_main_config_file |/bin/grep -q 'Things look okay'",
    require => Package["nagios"],
  }

  exec {"nagios-reload":
    command     => "/etc/init.d/nagios reload",
    refreshonly => true,
    onlyif      => "/usr/sbin/nagios -v $nagios_main_config_file |/bin/grep -q 'Things look okay'",
    require     => Package["nagios"],
  }

  file {"/etc/default/nagios": ensure => absent }

  file {"/etc/nagios3":
    ensure  => absent,
  }

  file {["/var/run/nagios3/",
         "/var/lib/nagios3/spool/",
         "/var/cache/nagios3/",
         "/var/lib/nagios3/spool/checkresults"
        ]:
    ensure => directory,
    owner  => nagios,
    group  => nagios,
    mode   => 0744,
    require => Package["nagios"],
    before  => Service["nagios"],
  }

  case $architecture {
    "i386": { $user1 = "/usr/lib/nagios/plugins" }
    "x86_64": { $user1 = "/usr/lib64/nagios/plugins" }
  }

  file {"$nagios_root_dir/resource.cfg":
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
    content => "
# file managed by puppet
\$USER1\$=$user1
",
  }

  common::concatfilepart {"main":
    file    => $nagios_main_config_file,
    content => template("nagios/nagios.cfg.erb"),
    notify  => Exec["nagios-reload"],
  }

  if defined( Class["apache"] ) {
    $group = "apache"
  } else {
    $group = "nagios"
  }

  file {"/var/log/nagios/rw":
    ensure => directory,
    owner  => nagios,
    group  => $group,
    mode   => 0755,
    require => Package["nagios"],
  }
  exec {"create node":
    require => File["/var/log/nagios/rw"],
    command => "mknod -m 0664 /var/log/nagios/rw/nagios.cmd p && chown nagios:${group} /var/log/nagios/rw/nagios.cmd",
    unless  => "test -p /var/log/nagios/rw/nagios.cmd"
  }
}
