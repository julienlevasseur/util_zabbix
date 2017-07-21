class Chef
  module Zabbix
    module Helpers

      def load_zabbix_gem
        require 'zabbixapi'
        Chef::Log.debug('Node has zabbixapi gem installed. No need to install gem.')
      rescue LoadError
        Chef::Log.debug('Did not find zabbixapi installed. Installing now')
      
        gem_package 'zabbixapi' do
        #chef_gem 'zabbixapi' do
          #compile_time true
          source '/home/vagrant/zabbixapi/zabbixapi-3.1.0.gem'
          #clear_sources true
          action :install
        end
        #chef_gem 'zabbixapi' do
        #  compile_time true
        #  action :install
        #end
      
        require 'zabbixapi'
      end

      def zbx_client
        load_zabbix_gem

        @url      = ENV['ZBX_URL'] || connection[:zabbix_server_url]
        @user     = ENV['ZBX_USER'] || connection[:zabbix_server_user]
        @password = ENV['ZBX_PASSWORD'] || connection[:zabbix_server_password]

        @zbx_client ||=
          ZabbixApi.connect(
            url: @url,
            user: @user,
            password: @password
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

      def get_valuemapid(valuemap_name)
        zbx_client.valuemaps.all.each do |valuemapname, valuemapid|
          return valuemapid.to_i if valuemapname == valuemap_name
        end
      end

      def valuemap_exists?(valuemap_name)
        return true if get_valuemapid(valuemap_name).is_a? Integer
      end
    end
  end
end
