property :id, Integer
property :description, String, name_property: true
property :expression, String
property :comments, String
property :error, String
property :flags, Integer
property :lastchange, String
property :priority, Integer # 0 - (default) not classified; 1 - information; 2 - warning; 3 - average; 4 - high; 5 - disaster.
#property :
property :status, Integer

default_action :create

include Chef::Zabbix::Helpers

def trigger_exists?

end

#action :update
#  unless trigger_exists?
#end
