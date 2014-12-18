require 'spec_helper_acceptance'

describe 'nagios class' do

  context 'with default parameters' do
    it 'should idempotently install' do
      pp = <<-EOS
        Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin' }
       
        if $::osfamily == 'RedHat' {
          class {'::selinux::base':}
        }

        class { '::nagios': }
  
        nagios::template {'generic-service':
          conf_type => 'service',
          content   => "
        active_checks_enabled           0
        passive_checks_enabled          0
        parallelize_check               1
        obsess_over_service             1
        check_freshness                 0
        notifications_enabled           1
        event_handler_enabled           1
        flap_detection_enabled          1
        failure_prediction_enabled      1
        process_perf_data               1
        retain_status_information       1
        retain_nonstatus_information    1
        notification_interval           0
        is_volatile                     0
        check_period                    24x7
        normal_check_interval           5
        retry_check_interval            1
        max_check_attempts              4
        notification_period             24x7
        notification_options            w,u,c,r
        contact_groups                  admins
        register                        0",
        }

        nagios::template {'generic-service-active':
          conf_type => 'service',
          content   => "
        use                    generic-service
        active_checks_enabled  1
        register               0",
        }

        nagios::host { $::hostname:}

        nagios::service::local {'check_ssh_process':
          use                 => 'generic-service-active',
          command_line        => '/usr/lib/nagios/plugins/check_procs -p 1 -w 1: -c 1: -C sshd',
          codename            => 'check_ssh_process',
          service_description => 'check_ssh', 
        }
      EOS
      
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
    
    describe service('nagios') do
      it { should be_running }
      it { should be_enabled }
    end
  end

end

