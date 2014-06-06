require 'spec_helper'

describe 'nagios' do
  let :pre_condition do
    "Exec { path => '/foo', }"
  end
  let(:facts) {{
    :concat_basedir  => '/foo',
    :id              => 'root',
    :kernel          => 'Linux',
    :operatingsystem => 'Debian',
    :osfamily        => 'Debian',
    :path            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }}
  it 'should compile' do
    should compile.with_all_deps
  end
end
