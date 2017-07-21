util_zabbix
===========

An LWRP that provide a basic management of Zabbix objects.

# Dependencies

* https://github.com/express42/zabbixapi

# Objects Import

Implementation of the configurations import :

the configuration resource support the following parameters :

  - applications
  - discoveryRules
  - graphs
  - groups
  - hosts
  - images
  - items
  - maps
  - screens
  - templateLinkage
  - templates
  - templateScreens
  - triggers
  - valueMaps

  (details here : https://www.zabbix.com/documentation/3.0/manual/api/reference/configuration/import )

So hosts or templates objects (for example) have their own resource in this cookbook which provide creation & deletion actions. But if you need to import a host or a template (or anything else listed above), you have to use the `import` action provided by the `configuration` resource.

As it's really difficult to link a configuration with an object after the import, the `import` action on configuration resource doesn't check for any existing object and will import the given object at any call.
Regarding that, I really suggest you to use the `$object_exists?` function in a `not_if` test when you import a configuration.

Example :

```ruby
util_zabbix_configuration 'config_test' do
  connection zbx_connection
  rules rules
  source lazy { ::File.open('/tmp/zabbix_template_test.xml', 'rb').read }
  not_if {template_exists?('Template TEST')}
end
```

Because you know what type of object you import in your wrapper cookbook, you can call the correct helper function (`template_exists?`, `host_exists?` ...) to make the import conditionnal.

# Usage

Zabbix expect credentials exported as env vars or a connection hash to be given to the resources :

```ruby
ENV['ZBX_URL']      = 'https://zabbix.example.com/zabbix/api_jsonrpc.php'
ENV['ZBX_USER']     = 'username'
ENV['ZBX_PASSWORD'] = 'P4s5w0rd'

zbx_connection = {
  zabbix_server_url: 'https://zabbix.example.com/zabbix/api_jsonrpc.php',
  zabbix_server_user: 'user',
  zabbix_server_password: 'p4s5w0rd'
}
```

## Host

```ruby

host_name = 'host.example.com'

# Creation
zabbix_host host_name do
  interfaces [{ type: 1, main: 1, useip: 1, ip: '127.0.0.1', dns: host_name, port: 10050 }]
  groups ['Linux servers']
  templates ['Template OS Linux']
  inventory_mode 0
  inventory nil
end

# Deletetion
zabbix_host host_name do
  action :delete
end
```

## Macro

```ruby

host_name = 'host.example.com'

# Creation
zabbix_macro '{$TEST}' do
  host_name host_name
  value 'TEST'
end

# Deletetion
zabbix_macro '{$TEST}' do
  host_name host_name
  action :delete
end
```

## Template

```ruby

# This cookbook file is the template in its XML format
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

# Creation
util_zabbix_configuration 'config_test' do
  rules rules
  source lazy { ::File.open('/tmp/zabbix_template_test.xml', 'rb').read }
  not_if {template_exists?('Template TEST Configuration')}
end

# Deletetion
util_zabbix_template 'Template TEST Configuration' do
  action :delete
end
```

## ValueMap

```ruby
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
```

# Links & Refs

http://www.rubydoc.info/gems/zabbixapi