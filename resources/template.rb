# rubocop:disable LineLength
# https://github.com/express42/zabbixapi/blob/master/examples/Templates.md
# https://www.zabbix.com/documentation/3.0/manual/api/reference/template
# rubocop:enable LineLength

resource_name :zabbix_template
provides :zabbix_template

property :name, String, name_property: true
property :groups, Array
property :connection, Hash, sensitive: true

default_action :create

include Chef::Zabbix::Helpers

action :create do
  unless template_exists?(new_resource.name)
    converge_by "Creating Zabbix Template '#{new_resource.name}'" do
      begin
        zbx_client.templates.create(
          host: 'template',
          groups: new_resource.groups
        )
        Chef::Log.debug("#{new_resource.name}: Creating Zabix Configuration [#{new_resource.name}]")
      rescue LoadError
        Chef::Log.error("Failed to create zabbix tempalte #{new_resource.name}")
      end
    end
  end
end

action :delete do
  converge_by "Deleting Zabbix Template '#{new_resource.name}'" do
    begin
      zbx_client.templates.delete(
        zbx_client.templates.get_id(
          host: new_resource.name.to_s
        )
      )
      Chef::Log.debug("#{new_resource.name}: Deleting Zabix Configuration [#{new_resource.name}]")
    rescue LoadError
      Chef::Log.error("Failed to delete zabbix template #{new_resource.name}")
    end
  end
end
