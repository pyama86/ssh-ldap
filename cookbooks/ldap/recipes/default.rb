#
# Cookbook Name:: ldap
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
%w(openldap-servers openldap-clients).each do |p|
  package "#{p}" do
    action :install
  end
end

service 'slapd' do
  action [:start, :enable]
end

execute "copy sample comfig" do
  command "cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG"
  not_if 'test -e /var/lib/ldap/DB_CONFIG'
end

directory '/etc/openldap/ldif' do
  action :create
end

%w(chrootpw chdomain base user_add).each do |ldif|
  template "/etc/openldap/ldif/#{ldif}.ldif" do
    action :create
  end
end

cookbook_file "/etc/openldap/schema/openssh.ldif" do
  action :create
end

%w(cosine nis inetorgperson openssh).each do |l|
  execute "#{l}" do
    command "ldapadd -c -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/#{l}.ldif"
    not_if "ldapsearch -x -LLL -D 'cn=config' -b 'cn=config' '(objectClass=*)' -w test | grep }#{l}"
  end
end

execute 'chrootpw' do
  command 'ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/ldif/chrootpw.ldif'
  not_if "ldapsearch -x -D cn=Manager,dc=#{node['ldap']['company']},dc=com -wtest;test $? -eq 32"
end

execute 'chdomain' do
  command 'ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/ldif/chdomain.ldif'
  not_if "ldapsearch -x -D cn=Manager,dc=#{node['ldap']['company']},dc=com -wtest;test $? -eq 32"
end

execute 'base' do
  command "ldapadd -x -D cn=Manager,dc=#{node['ldap']['company']},dc=com -w test -f /etc/openldap/ldif/base.ldif"
  not_if "ldapsearch -x -D cn=Manager,dc=#{node['ldap']['company']},dc=com -w test -b ou=ssh,dc=#{node['ldap']['company']},dc=com | grep organizationalUnit"
end

execute 'user_add' do
  command "ldapadd -c -x -D cn=Manager,dc=#{node['ldap']['company']},dc=com -w test -f /etc/openldap/ldif/user_add.ldif"
  not_if "ldapsearch -x -D cn=Manager,dc=#{node['ldap']['company']},dc=com -w test -b ou=ssh,dc=#{node['ldap']['company']},dc=com uid=#{node['ldap']['user']} | grep shadowAccount"
end
