Chef::Log.info("******* Entering iterfaces.rb, the inetrface name is #{node[:openvswitch][:eth_name]}")

template "/root/interfaces-setup.sh" do
  source "interfaces-setup.sh"
  owner "root"
  group "root"
  mode 0755
  variables ({
  :mgmtip => node[:openvswitch][:mgmtip],
  :mgmtmask => node[:openvswitch][:mgmtmask],
  :dataip => node[:openvswitch][:dataip],
  :datamask => node[:openvswitch][:datamask]
  })
end

service "network"

bash "install and start interface" do
  user "root"
  code <<-EOH
  cd /root
  ./interfaces-setup.sh #{node[:openvswitch][:eth_name]} > output.txt 
  EOH
  notifies :restart, "service[network]" 
end

Chef::Log.info("******* Sleep for 30 secods to allow the network to restart..")

sleep(30)
