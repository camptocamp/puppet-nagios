import "classes/*.pp"
import "definitions/*.pp"

class nagios {
  case $operatingsystem {
    Debian:  { include nagios::debian}
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
