require 'chefspec'
require 'chefspec/policyfile'
require 'chefspec/cacher'

VAULT_VERSION = '0.11.0'.freeze
describe 'hashicorp-vault::default' do
  before do
    stub_command("test -L /opt/vault/#{VAULT_VERSION}/vault").and_return(true)
    stub_command("getcap /opt/vault/#{VAULT_VERSION}/vault|grep cap_ipc_lock+ep").and_return(false)
  end

  context 'with default node attributes' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04').converge('hashicorp-vault::default')
    end

    it { expect(chef_run).to create_poise_service_user('vault').with(group: 'vault') }
    it { expect(chef_run).to create_vault_config('/etc/vault/vault.json') }
    it { expect(chef_run).to create_vault_installation(VAULT_VERSION) }
    it { expect(chef_run).to enable_vault_service('vault').with(config_path: '/etc/vault/vault.json') }
    it { expect(chef_run).to start_vault_service('vault') }
  end
end
