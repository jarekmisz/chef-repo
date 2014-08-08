log_level                :info
log_location             STDOUT
node_name                'jarek-jb'
client_key               '/home/jarek/chef-repo/.chef/jarek-jb.pem'
validation_client_name   'chef-validator'
validation_key           '/home/jarek/chef-repo/.chef/chef-validator.pem'
chef_server_url          'https://sde-xcat-pre.pok.ibm.com:443'
syntax_check_cache_path  '/home/jarek/chef-repo/.chef/syntax_check_cache'
cookbook_path [ './cookbooks' ]
