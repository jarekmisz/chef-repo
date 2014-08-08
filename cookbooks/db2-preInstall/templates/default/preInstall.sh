#! /bin/bash
# Fix the etc/hosts file
tee -a /etc/hosts <<EOF
<%= @ipaddress %> <%= @hostname %> <%= @fqn %>
EOF

#Fix the DNS
tee /etc/resolv.conf <<EOF
search <%= @domain %>
nameserver <%= @nameserver %>
EOF

#Fix sshd to allow password access. The service will be restarted in the recipe.
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config

#Set up the yum repo
tee /etc/yum.repos.d/ibm-yum.repo <<EOF
[ftp3]
name=FTP3 yum repository
baseurl=ftp://<%= @ftp3user %>:<%= @ftp3password%>@ftp3install.linux.ibm.com/redhat/yum/6/server/os/x86_64/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
[ftp3-updates]
name=FTP3 updates yum repository
baseurl=ftp://<%= @ftp3user %>:<%= @ftp3password%>@ftp3install.linux.ibm.com/redhat/yum/6/server/updates/x86_64/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
[ftp3-supplementary]
name=FTP3 supplementary yum repository
baseurl=ftp://<%= @ftp3user %>:<%= @ftp3password%>@ftp3install.linux.ibm.com/redhat/yum/6/server/supplementary/x86_64/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
[ftp3-optional]
name=FTP3 optional yum repository
baseurl=ftp://<%= @ftp3user %>:<%= @ftp3password%>@ftp3install.linux.ibm.com/redhat/yum/6/server/optional/x86_64/
[ftp3-ha]
name=FTP3 ha yum repository
baseurl=ftp://<%= @ftp3user %>:<%= @ftp3password%>@ftp3install.linux.ibm.com/redhat/yum/6/server/ha/x86_64/
[ftp3-lb]
name=FTP3 lb yum repository
baseurl=ftp://<%= @ftp3user %>:<%= @ftp3password%>@ftp3install.linux.ibm.com/redhat/yum/6/server/lb/x86_64/
[ftp3-v2vwin]
name=FTP3 v2vwin yum repository
baseurl=ftp://<%= @ftp3user %>:<%= @ftp3password%>@ftp3install.linux.ibm.com/redhat/yum/6/server/v2vwin/x86_64/
EOF