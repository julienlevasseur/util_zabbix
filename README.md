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

# Links & Refs

http://www.rubydoc.info/gems/zabbixapi