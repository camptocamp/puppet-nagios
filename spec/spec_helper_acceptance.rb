require 'beaker-rspec'

hosts.each do |host|
  # Install puppet
  install_puppet_agent_on host, {}
  install_package host, 'git'
  case fact('osfamily')
  when 'Debian'
    install_package host, 'libaugeas-ruby'
  when 'RedHat'
    install_package host, 'net-tools'
    install_package host, 'gcc'
    install_package host, 'ruby-devel'
    install_package host, 'augeas-devel'
    on host, 'gem install ruby-augeas --no-ri --no-rdoc'
  else
    puts 'Sorry, this osfamily is not supported.'
    exit
  end
end

###
# Copied/pasted/adapted from puppetlabs_spec_helper's lib/puppetlabs_spec_helper/rake_tasks.rb
#
def fixtures(host, category)
  begin
    fixtures = YAML.load_file(".fixtures.yml")["fixtures"]
  rescue Errno::ENOENT
    return {}
  end

  if not fixtures
    abort("malformed fixtures.yml")
  end

  result = {}
  if fixtures.include? category and fixtures[category] != nil
    fixtures[category].each do |fixture, opts|
      if opts.instance_of?(String)
        source = opts
        target = "#{host['distmoduledir']}/#{fixture}"
        real_source = eval('"'+source+'"')
        result[real_source] = target
      elsif opts.instance_of?(Hash)
        target = "#{host['distmoduledir']}/#{fixture}"
        real_source = eval('"'+opts["repo"]+'"')
        result[real_source] = { "target" => target, "ref" => opts["ref"], "scm" => opts["scm"] }
      end
    end
  end
  return result
end

def clone(host, scm, remote, target, ref=nil)
  args = []
  case scm
  when 'hg'
    args.push('clone')
    args.push('-u', ref) if ref
    args.push(remote, target)
  when 'git'
    args.push('clone', remote, target)
  else
      fail "Unfortunately #{scm} is not supported yet"
  end
  on host, "#{scm} #{args.flatten.join ' '} || true"
end

#def revision(scm, target, ref)
def revision(host, scm, target, ref)
  args = []
  case scm
  when 'hg'
    args.push('update', 'clean', '-r', ref)
  when 'git'
    args.push('reset', '--hard', ref)
  else
      fail "Unfortunately #{scm} is not supported yet"
  end
  on host, "cd #{target} && #{scm} #{args.flatten.join ' '}"
end

def spec_prep(host)
  fixtures(host, "repositories").each do |remote, opts|
    scm = 'git'
    if opts.instance_of?(String)
      target = opts
    elsif opts.instance_of?(Hash)
      target = opts["target"]
      ref = opts["ref"]
      scm = opts["scm"] if opts["scm"]
    end

    unless File::exists?(target) || clone(host, scm, remote, target, ref)
      fail "Failed to clone #{scm} repository #{remote} into #{target}"
    end
    #revision(scm, target, ref) if ref
    revision(host, scm, target, ref) if ref
  end

  fixtures(host, "forge_modules").each do |remote, opts|
    if opts.instance_of?(String)
      target = opts
      ref = ""
    elsif opts.instance_of?(Hash)
      target = opts["target"]
      ref = "--version #{opts['ref']}"
    end
    next if File::exists?(target)
    on host, puppet('module', 'install', ref), { :acceptable_exit_codes => [0,1] }
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
    puppet_module_install(:source => proj_root, :module_name => 'nagios')
    hosts.each do |host|
      spec_prep(host)
    end
  end
end
