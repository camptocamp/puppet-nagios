class nagios::base::withwebinterface inherits nagios::base {
  File["nagios read-write dir"] {
    group   => "${apache::params::user}",
  }
}
