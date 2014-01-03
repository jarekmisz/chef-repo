Chef::Log.info("******* Enetring iterfaces.rb, the inetrface name is #{node[:openvswitch][:eth_name]}")

template "/root/interfaces-setup.sh" do
  source "interfaces-setup.sh"
  owner "root"
  group "root"
  mode 0755
end

service "network"

bash "install and start interface" do
  user "root"
  code <<-EOH
  cd /root
  ./interfaces-setup.sh #{node[:openvswitch][:eth_name]}
  EOH
  
  notifies :restart, "service[network]"
end

