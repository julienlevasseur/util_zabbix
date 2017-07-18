#
# Cookbook Name:: util_zabbix
# Recipe:: smoke
#

zbx_connection = {
  zabbix_server_url: 'https://zabbix.example.com/zabbix/api_jsonrpc.php',
  zabbix_server_user: 'user',
  zabbix_server_password: 'password'
}

host_name = 'util_zabbix_smoke_test'

zabbix_host host_name do
  connection zbx_connection
  interfaces [{ type: 1, main: 1, useip: 1, ip: '127.0.0.1', dns: host_name, port: 10050 }]
  host host_name
  groups ['Linux servers']
  templates ['Template OS Linux']
  inventory_mode 0
  inventory nil
end

zabbix_macro '{$SMOKETEST}' do
  connection zbx_connection
  host_name host_name
  value 'TEST'
end

zabbix_macro '{$SMOKETEST}' do
  connection zbx_connection
  host_name host_name
  action :delete
end

zabbix_host host_name do
  connection zbx_connection
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

util_zabbix_configuration 'config_test' do
  connection zbx_connection
  rules rules
  source lazy { ::File.open('/tmp/zabbix_template_test.xml', 'rb').read }
  not_if {template_exists?('Template TEST Configuration')}
end

util_zabbix_template 'Template TEST Configuration' do
  connection zbx_connection
  action :delete
end
