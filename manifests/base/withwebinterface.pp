class nagios::base::withwebinterface inherits nagios::base {
  File["nagios read-write dir"] {
    group   => "${apache_c2c::params::user}",
  }
}
