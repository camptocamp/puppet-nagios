class nagios::debian inherits nagios::base {

  file {"/etc/apache2/conf.d/nagios3.conf":
    ensure  => absent,
    notify  => Exec["apache-graceful"],
  }
    
}
