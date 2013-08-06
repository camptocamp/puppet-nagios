class nagios {
  case $::osfamily {
    'Debian': { include nagios::debian }
    'RedHat': { include nagios::redhat }
    default:  { fail ("OS family ${::osfamily} not yet implemented !")}
  }
}
