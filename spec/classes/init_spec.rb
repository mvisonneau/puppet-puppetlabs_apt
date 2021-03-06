require 'spec_helper'

shared_examples 'shared examples' do
  it { should compile.with_all_deps }
  it { should contain_class('apt') }
  it { should contain_class('puppetlabs_apt') }
  it { should contain_package('puppetlabs-release') }
  it { should contain_apt_key('Add key: 1054B7A24BD6EC30 from Apt::Source puppetlabs') }
  it { should contain_apt__source('puppetlabs').with_location('http://apt.puppetlabs.com/') }
end

describe 'puppetlabs_apt' do
  describe 'puppetlabs_apt class on Debian' do
    let(:facts) {{
      :osfamily  => 'Debian',
      :lsbdistid => 'Debian',
      :lsbdistcodename => 'wheezy',
    }}
    context "without any parameters" do
      let(:params) {{ }}

      it_behaves_like "shared examples"
      it { should contain_apt__source('puppetlabs').with_repos('main dependencies') }
    end
    context "with enable_devel => true" do
      let(:params) { {:enable_devel => true} }

      it_behaves_like "shared examples"
      it { should contain_apt__source('puppetlabs').with_repos('main dependencies devel') }
    end
  end

  context 'undef release codename' do
    let(:params) {{ }}
    let(:facts) {{
      :osfamily  => 'Debian',
      :lsbdistid => 'Debian',
      :lsbdistcodename => nil,
    }}

    it { expect { should contain_package('puppetlabs_release') }.to raise_error(Puppet::Error, /Failed to determine the release codename/) }
  end

  context 'unsupported operating system' do
    describe 'puppetlabs_apt class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should contain_package('puppetlabs_release') }.to raise_error(Puppet::Error, /This module only works on Debian or derivatives like Ubuntu/) }
    end
  end
end
