require 'spec_helper'

describe 'nagios' do
  let :pre_condition do
    "Exec { path => '/foo', }"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir  => '/foo',
        })
      end

      it 'should compile' do
        should compile.with_all_deps
      end
    end
  end
end
