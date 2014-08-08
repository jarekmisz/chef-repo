#
# Cookbook Name:: db2-preInstall
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

Chef::Log.info("******* The node's hostname is #{node['hostname']}.")
Chef::Log.info("******* The node's network IP address is #{node['ipaddress']}")

template "/root/db2-preInstall.sh" do
  source "db2-preInstall.sh"
  owner "root"
  group "root"
  mode 0755
  variables ({
  :ipaddress => node['ipaddress'],
  :hostname => node['hostname'],
  :fqn => node['hostname'] + '.' + node[:db2_preinstall][:domain],
  :domain => node[:db2_preinstall][:domain],
  :nameserver => node[:db2_preinstall][:nameserver],
  :ftp3user => node[:db2_preinstall][:ftp3user],
  :ftp3password => node[:db2_password][:ftp3user]
  })
end

service "sshd"

bash "Cleanup the VM configuration" do
  user "root"
  code <<-EOH
  cd /root
  ./db2-preInstall.sh > output.txt 
  EOH
  
  notifies :restart, "service[ssd]", :immediately 
end