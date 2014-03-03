# == Definition: nagios::webadmin
#
# Simple wrapper to ease apache configuration for nagios.
#
define nagios::webadmin(
  $vhost,
  $htpasswd_file,
  $ensure        = present,
) {

  file {"/var/www/${vhost}/conf/nagios.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('nagios/apache.conf.erb'),
    notify  => Exec['apache-graceful'],
  }

}
