class nagios(
  $use_syslog      = '1',
  $check_ping_ipv  = $nagios_check_ping_ipv,
  $nrpe_server_tag = $::fqdn,
) {
  case $::osfamily {
    'Debian': { include nagios::debian }
    'RedHat': { include nagios::redhat }
    default:  { fail ("OS family ${::osfamily} not yet implemented !")}
  }
}
