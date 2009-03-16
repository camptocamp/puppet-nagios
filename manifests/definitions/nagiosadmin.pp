define nagios::webadmin ($ensure=present, $password) {

  $vhost = $name
  
  file {"/var/www/$vhost/private/nagios-htpasswd":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => 644,
    require => Apache::Vhost-ssl[$vhost],
  }

  line {"set nagios admin password $password":
    line    => "nagiosadmin:${password}",
    ensure  => $ensure,
    file    => "/var/www/$vhost/private/nagios-htpasswd",
    require => File["/var/www/$vhost/private/nagios-htpasswd"],
  }

  file {"/var/www/$vhost/conf/nagios.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("nagios/apache.conf.erb"),
    require => File["/var/www/$vhost/private/nagios-htpasswd"],
    notify  => Exec["apache-graceful"],
  }

}
