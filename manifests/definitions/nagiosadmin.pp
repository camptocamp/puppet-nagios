define nagios::webadmin ($ensure=present, $password) {
  
  file {"/var/www/$name/private/nagios-htpasswd":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => 644,
    require => Apache::Vhost-ssl[$name],
  }

  line {"set nagios admin password $password":
    line    => "nagiosadmin:${password}",
    ensure  => $ensure,
    file    => "/var/www/$name/private/nagios-htpasswd",
    require => File["/var/www/$name/private/nagios-htpasswd"],
  }

  file {"/var/www/$name/conf/nagios.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("nagios/apache.conf.erb"),
    require => File["/var/www/$name/private/nagios-htpasswd"],
    notify  => Exec["apache-graceful"],
  }

}
