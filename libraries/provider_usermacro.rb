require_relative 'helpers'
include Chef::Zabbix::Helpers

class Chef
  class Provider
    class Zabbix
      class Macro < Chef::Provider::LWRPBase
        use_inline_resources

        def whyrun_supported
          true
        end

        action :create do
          unless usermacro_exists
            converge_by "Creating Zabbix Macro '#{new_resource.name}'" do
              begin
                zbx_client.usermacros.create(
                  host_name: get_host_id(new_resource.host_name),
                  macro: new_resource.macro,
                  value: new_resource.value
                )
                Chef::Log.debug("#{new_resource.name}: Creating Zabbix Macro [#{new_resource.name}]")
              rescue LoadError
                Chef::Log.error("Failed to create zabbix macro #{new_resource.name}")
              end
            end
          end
        end
      end
    end
  end
end
