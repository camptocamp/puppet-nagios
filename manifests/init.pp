class nagios(
  $use_syslog     = pick($nagios_use_syslog, '1'),
  $check_ping_ipv = $nagios_check_ping_ipv,
) {
  case $::osfamily {
    'Debian': { include nagios::debian }
    'RedHat': { include nagios::redhat }
    default:  { fail ("OS family ${::osfamily} not yet implemented !")}
  }
}
