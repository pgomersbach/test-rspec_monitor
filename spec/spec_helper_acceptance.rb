require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'rspec_monitor')
    hosts.each do |host|
      on host ,shell('mkdir /tmp/modules')
      scp_to host, "#{proj_root}/spec/fixtures/modules/", "/tmp", {:ignore => ["rspec_monitor", ".bundle", ".git", ".idea", ".vagrant", ".vendor", "vendor", "acceptance", "bundle", "spec", "tests", "log", ".", ".."]}
      on host, shell('mv /tmp/modules/* /etc/puppet/modules')
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
