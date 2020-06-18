class nagios(
  Enum['present', 'absent'] = 'present',
  $use_syslog               = '1',
  $check_ping_ipv           = undef,
  $nrpe_server_tag          = $::fqdn,
  $nsca_server_tag          = $::fqdn,
  $niceness                 = 5,
) {
  case $::osfamily {
    'Debian': { include ::nagios::debian }
    'RedHat': { include ::nagios::redhat }
    default:  { fail ("OS family ${::osfamily} not yet implemented !")}
  }
}
