#
# Cookbook Name:: sde-ovs-setup
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

directory node[:openvswitch][:conf_dir] do
  owner "root"
  group "root"
  mode 00755
end

if Dir[(node[:openvswitch][:conf_dir])] == []
  bash "install openswitch from code" do
    user "root"
    code <<-EOH
      cd /var/opt
      wget #{node[:openvswitch][:rpm_url]}
      yum install openvswitch*.rpm
      EOH
  end
end

service "openvswitch" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :start => true, :stop => true
  action [:enable, :start]
end