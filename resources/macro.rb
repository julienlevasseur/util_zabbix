resource_name :zabbix_macro
provides :zabbix_macro

property :name, String, name_property: true
property :host_name, String
property :connection, Hash, sensitive: true
property :value, String

default_action :create

include Chef::Zabbix::Helpers

action :create do
  unless usermacro_exists?(new_resource.name, new_resource.host_name)
    converge_by "Creating Zabbix Macro '#{new_resource.name}' for Host '#{new_resource.host_name}'" do
      begin
        zbx_client.usermacros.create_or_update(
          hostid: get_host_id(new_resource.host_name),
          macro: new_resource.name,
          value: new_resource.value
        )
        Chef::Log.debug("#{new_resource.name}: Creating Zabbix Macro [#{new_resource.name}] for Host [#{new_resource.host_name}]")
      rescue LoadError
        Chef::Log.error("Failed to create Zabbix Macro [#{new_resource.name}] for Host [#{new_resource.host_name}]")
      end
    end
  end
end

action :delete do
  if usermacro_exists?(new_resource.name, new_resource.host_name)
    converge_by "Deleting Zabbix Macro '#{new_resource.name}' for Host '#{new_resource.host_name}'" do
      begin
        zbx_client.usermacros.delete(get_macro_id(new_resource.name, new_resource.host_name).to_s)
        Chef::Log.debug("#{new_resource.name}: Deleting Zabbix Macro [#{new_resource.name}] for Host [#{new_resource.host_name}]")
      rescue LoadError
        Chef::Log.error("Failed to delete Zabbix Macro '#{new_resource.name}' for Host '#{new_resource.host_name}'")
      end
    end
  end
end
