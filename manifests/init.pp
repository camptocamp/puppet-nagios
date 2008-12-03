
case $operatingsystem {
  Debian: {

    # main configuration
    $nagios_root_dir="/etc/nagios3"
    $nagios_cfg_dir="${nagios_root_dir}/auto-puppet"
    $nagios_main_config_file="${nagios_root_dir}/nagios.cfg"
    
    # nsca configuration
    $nagios_nsca_printf="/usr/bin/printf"
    $nagios_nsca_bin="/usr/sbin/send_nsca"
    $nagios_nsca_cfg="/etc/nsca.cfg"
    $nagios_send_nsca_cfg="/etc/send_nsca.cfg"

    # web interface
    $nagios_cgi_dir="/usr/lib/cgi-bin/nagios3"
    $nagios_physical_html_path="/usr/share/nagios3/htdocs"
    $nagios_stylesheets_dir="$nagios_root_dir/stylesheets" 
    $nagios_show_context_help="0"

  }
}

import "classes/*.pp"
import "definitions/*.pp"
