# rubocop:disable LineLength
# http://www.rubydoc.info/gems/zabbixapi/ZabbixApi/Configurations
# https://www.zabbix.com/documentation/3.0/manual/api/reference/configuration/import
# rubocop:enable LineLength
property :name, String, name_property: true
property :format, String, default: 'xml'
property :rules, Hash, sensitive: true
property :source, String, sensitive: true
property :connection, Hash, sensitive: true

# rules example for a template :
# rules: {
#   templates: {
#     createMissing: true,
#     updateExisting: true
#   },
#   items: {
#     createMissing: true,
#     updateExisting: true
#   }
# }
#

default_action :import

include Chef::Zabbix::Helpers

action :import do
  converge_by "Importing Zabbix Configuration '#{new_resource.name}'" do
    begin
      zbx_client.configurations.import(
        format: new_resource.format,
        rules: new_resource.rules,
        source: new_resource.source
      )
      Chef::Log.debug("#{new_resource.name}: Importing Zabix Configuration [#{new_resource.name}]")
    rescue LoadError
      Chef::Log.error("Failed to import zabbix configuration #{new_resource.name}")
    end
  end
end

action :export do
  converge_by "Exporting Zabbix Configuration '#{new_resource.name}'" do
    begin
      zbx_client.configurations.export(
        format: new_resource.format,
        options: {
          templates: [zbx_client.templates.get_id(host: new_resource.name)]
        }
      )
      Chef::Log.debug("#{new_resource.name}: Exporting Zabix Configuration [#{new_resource.name}]")
    rescue LoadError
      Chef::Log.error("Failed to export zabbix configuration #{new_resource.name}")
    end
  end
end
