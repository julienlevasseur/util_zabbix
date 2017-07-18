class Chef
  module Zabbix
    module Helpers

      def load_zabbix_gem
        require 'zabbixapi'
        Chef::Log.debug('Node has zabbixapi gem installed. No need to install gem.')
      rescue LoadError
        Chef::Log.debug('Did not find zabbixapi installed. Installing now')
      
        chef_gem 'zabbixapi' do
          compile_time true
          action :install
        end
      
        require 'zabbixapi'
      end

      def zbx_client
        load_zabbix_gem
        @zbx_client ||=
          ZabbixApi.connect(
            url: connection[:zabbix_server_url],
            user: connection[:zabbix_server_user],
            password: connection[:zabbix_server_password]
          )
      end

      def get_host_id(hostname)
        zbx_client.hosts.get_id( host: hostname )
      end

      def host_triggers(hostname)
        return zbx_client.query(
          method: 'trigger.get',
          params: {
            filter: {
              host: hostname
            },
            output: 'extend'
          }
        )
      end

      def list_hosts
        zbx_client.hosts.all
      end
      
      def host_exists?(host_name)
        return true if zbx_client.hosts.get_id( :host => "#{host_name}" ).is_a? Integer
      end

      def get_template_id(template_name)
        zbx_client.templates.get_id( host: "#{template_name}" )
      end
      
      def template_exists?(template_name)
        return true if get_template_id(template_name).is_a? Integer
      end

      def get_macro_id(macro_name, host_name)
        zbx_client.usermacros.get_id( macro: "#{macro_name}", hostid: get_host_id("#{host_name}") )
      end
      
      def usermacro_exists?(macro_name, host_name)
        return true if get_macro_id(macro_name, host_name).is_a? Integer
      end
    end
  end
end
