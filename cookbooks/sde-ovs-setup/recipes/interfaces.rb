sde_node_name=node['hostname']

Chef::Log.info("******* The node's hostname is #{sde_node_name}. It will be used to retrieve node's attributes from the sed_nodes data bag...")

sde_node = search(:sdenodes, "id:#{sde_node_name}").first

Chef::Log.info("******* The node's network interface name is #{sde_node['eth_name']}")

template "/root/interfaces-setup.sh" do
  source "interfaces-setup.sh"
  owner "root"
  group "root"
  mode 0755
  variables ({
  :mgmtip => sde_node['mgmtip'],
  :mgmtmask => sde_node['mgmtmask'],
  :dataip => sde_node['dataip'],
  :datamask => sde_node['datamask']
  })
end

service "network"

bash "install and start interface" do
  user "root"
  code <<-EOH
  cd /root
    ./interfaces-setup.sh "#{sde_node['eth_name']}" > output.txt 
  EOH
  notifies :restart, "service[network]", :immediately 
end
