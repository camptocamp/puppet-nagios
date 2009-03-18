define nagios::webadmin ($ensure=present, $vhost, $htpasswd_file) {

  file {"/var/www/$vhost/conf/nagios.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("nagios/apache.conf.erb"),
    require => File["/var/www/$vhost/private/$htpasswd_file"],
    notify  => Exec["apache-graceful"],
  }

}
