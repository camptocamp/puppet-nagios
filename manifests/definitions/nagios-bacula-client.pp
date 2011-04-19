class nagios::bacula::client {

  @@nagios_service { "check_bacula_client_$fqdn":
    check_command => "check_bacula_client!$fqdn!36h!72h",
    host_name => $hostname,
    normal_check_interval => 60,
    notify => Service[nagios],
    service_description => Backup,
    use => local-service,
  }

}
