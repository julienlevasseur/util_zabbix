#
# Cookbook Name:: util_zabbix
# Recipe:: smoke
#

ENV['ZBX_URL']      = 'https://zabbix.example.com/zabbix/api_jsonrpc.php'
ENV['ZBX_USER']     = 'username'
ENV['ZBX_PASSWORD'] = 'P4s5w0rd'

host_name = 'util_zabbix_smoke_test'

zabbix_host host_name do
  interfaces [{ type: 1, main: 1, useip: 1, ip: '127.0.0.1', dns: host_name, port: 10050 }]
  groups ['Linux servers']
  templates ['Template OS Linux']
  inventory_mode 0
  inventory nil
end

zabbix_macro '{$SMOKETEST}' do
  host_name host_name
  value 'TEST'
end

zabbix_macro '{$SMOKETEST}' do
  host_name host_name
  action :delete
end

mappings = [
  {
    value: '0',
    newvalue: 'Down'
  }
]

zabbix_valuemap 'TEST' do
  mappings mappings
end

zabbix_valuemap 'TEST' do
  action :delete
end

zabbix_host host_name do
  action :delete
end

cookbook_file '/tmp/zabbix_template_test.xml' do
  source 'zabbix_template_test.xml'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

rules = {
  templates: {
    createMissing: true,
    updateExisting: true
  },
  items: {
    createMissing: true,
    updateExisting: true
  }
}

zabbix_configuration 'config_test' do
  rules rules
  source lazy { ::File.open('/tmp/zabbix_template_test.xml', 'rb').read }
  not_if {template_exists?('Template TEST Configuration')}
end

zabbix_template 'Template TEST Configuration' do
  action :delete
end
