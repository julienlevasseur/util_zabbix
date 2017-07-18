resource_name :zabbix_host
provides :zabbix_host

property :name, String, name_property: true
property :connection, Hash, sensitive: true
property :interfaces, Array
property :groups, Array
property :templates, Array
property :inventory_mode, Integer
property :inventory, Hash
property :macros, Array

default_action :create_or_update

include Chef::Zabbix::Helpers

action :create_or_update do
  unless host_exists?(new_resource.name)
    converge_by "Creating Zabbix Host '#{new_resource.name}'" do
      begin
        g = []
        new_resource.groups.each do |group|
          g.push({ groupid: zbx_client.hostgroups.get_id(name: group) })
        end
        # For each template, get it's id :
        t = []
        new_resource.templates.each do |tmpl|
          t.push({ templateid: zbx_client.templates.get_id(host: tmpl) })
        end
        hostid = zbx_client.hosts.get_id(host: new_resource.name)
        unless hostid.nil?
          zbx_client.hosts.update(
            hostid: hostid,
            groups: g,
            templates: t,
            macros: new_resource.macros,
            inventory_mode: new_resource.inventory_mode,
            inventory: new_resource.inventory
          )
          interface = zbx_client.query(
            method: "hostinterface.get",
            params: {
              output: "extend",
              hostids: hostid,
              filter: {:main => 1, :type => 1}
          }).first#["interfaceid"]
          zbx_client.query(
            method: "hostinterface.update",
            params: {
            interfaceid: interface['interfaceid'],
            ip: interface['ip'],
            dns: interface['dns'],
            port: interface['port'],
            useip: interface['useip'] 
          })
        else
          zbx_client.hosts.create_or_update(
            host: new_resource.host,
            interfaces: new_resource.interfaces,
            groups: g,
            templates: t,
            macros: new_resource.macros,
            inventory_mode: new_resource.inventory_mode,
            inventory: new_resource.inventory
          )
        end
        Chef::Log.debug("#{new_resource.name}: Creating Zabbix Host [#{new_resource.name}]")
      rescue LoadError
        Chef::Log.error("Failed to create zabbix host #{new_resource.name}")
      end
    end
  end
end

action :delete do
  converge_by "Deleting Zabbix Host '#{new_resource.name}'" do
    begin
      zbx_client.hosts.delete zbx_client.hosts.get_id(host: new_resource.name)
      Chef::Log.debug("#{new_resource.name}: Deleting Zabbix Host [#{new_resource.name}]")
    rescue
      Chef::Log.error("Failed to delete zabbix host #{new_resource.name}")
    end
  end
end
