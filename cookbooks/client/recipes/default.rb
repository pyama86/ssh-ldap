#
# Cookbook Name:: client
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w(authconfig openldap-clients nss-pam-ldapd openssh-ldap).each do |p|
  package "#{p}" do
    action :install
  end
end

service "sshd" do
  action [:start, :enable] 
end

cookbook_file '/etc/ssh/sshd_config' do
  action :create
  notifies :restart, 'service[sshd]'
end

template '/etc/ssh/ldap.conf' do
  source 'ssh_ldap.conf.erb'
  action :create
  notifies :restart, 'service[sshd]'
end

template '/etc/nslcd.conf' do
  action :create
  notifies :restart, 'service[nslcd]'
end

service 'nslcd' do
  action [:start, :enable]
end

bash 'auth_config' do
  code <<-EOS
    authconfig \
     --enableldap \
     --enableldapauth \
     --ldapserver="ldap://192.168.70.10/" \
     --ldapbasedn="ou=ssh,dc=#{node['client']['company']},dc=com" \
     --enablemkhomedir \
     --update
  EOS
  notifies :restart, 'service[nslcd]'
end
