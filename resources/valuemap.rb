resource_name :zabbix_valuemap
provides :zabbix_valuemap

property :name, String, name_property: true
property :connection, Hash, sensitive: true
property :mappings, Array

default_action :create_or_update

include Chef::Zabbix::Helpers

action :create_or_update do
  unless valuemap_exists?(new_resource.name)
    converge_by "Creating Zabbix ValueMap '#{new_resource.name}'" do
      begin
        zbx_client.valuemaps.create_or_update(
          name: new_resource.name,
          mappings: new_resource.mappings
        )
        Chef::Log.debug("#{new_resource.name}: Creating Zabbix ValueMap [#{new_resource.name}]")
      rescue LoadError
        Chef::Log.error("Failed to create zabbix valuemap #{new_resource.name}")
      end
    end
  end
end

action :delete do
  if valuemap_exists?(new_resource.name)
    converge_by "Deleting Zabbix ValueMap '#{new_resource.name}'" do
      begin
        zbx_client.valuemaps.delete(
          get_valuemapid(new_resource.name).to_s
        )
        Chef::Log.debug("#{new_resource.name}: Deleting Zabbix ValueMap [#{new_resource.name}]")
      rescue LoadError
        Chef::Log.error("Failed to delete zabbix valuemap #{new_resource.name}")
      end
    end
  end
end
