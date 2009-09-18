class nagios::os {
  case $operatingsystem {
    Debian: { include nagios::debian }

    Redhat: { include nagios::redhat }

    default: {err ("operatingsystem $operatingsystem not yet implemented !")}
  }
}
