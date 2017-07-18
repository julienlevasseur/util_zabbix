
#if defined?(ChefSpec)
#  ChefSpec.define_matcher :zabbix_host
#
#  def create_zabbix_host(resource_name)
#    ChefSpec::Matchers::ResourceMatcher.new(:zabbix_host, :create_or_update, resource_name)
#  end
#end
