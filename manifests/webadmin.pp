/*
== Definition: nagios::webadmin

Simple wrapper to ease apache configuration for nagios.

*/
define nagios::webadmin ($ensure=present, $vhost, $htpasswd_file) {

  file {"/var/www/$vhost/conf/nagios.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("nagios/apache.conf.erb"),
    notify  => Exec["apache-graceful"],
  }

}
