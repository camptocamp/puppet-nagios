class nagios::os {
  case $operatingsystem {
    /Debian|Ubuntu/: { include nagios::debian }

    /Redhat|CentOS/: { include nagios::redhat }

    default: {err ("operatingsystem $operatingsystem not yet implemented !")}
  }
}
