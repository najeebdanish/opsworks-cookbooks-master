require 'resolv'
include_recipe 's3'

package '389-ds'

s3_file "/etc/dirsrv_etc.tar.gz" do
  source "s3://opsworks-test01/dirsrv_etc.tar.gz"
  access_key_id #{node[:ldap389][:access_key_id]}
  secret_access_key #{node[:ldap389][:secret_access_key]}
  owner "root"
  group "root"
  mode 0644
end

execute "tar xvfz /etc/dirsrv_etc.tar.gz" do
  cwd "/etc"
end

s3_file "/usr/lib64/dirsrv_usrlib64.tar.gz" do
  source "s3://opsworks-test01/dirsrv_usrlib64.tar.gz"
  access_key_id #{node[:ldap389][:access_key_id]}
  secret_access_key #{node[:ldap389][:secret_access_key]}
  owner "root"
  group "root"
  mode 0644
end

execute "tar xvfz /usr/lib64/dirsrv_usrlib64.tar.gz" do
  cwd "/usr/lib64"
end

s3_file "/var/lib/dirsrv/slapd-dcaldap01b_varlibdirsrv.tar.gz" do
  source "s3://opsworks-test01/slapd-dcaldap01b_varlibdirsrv.tar.gz"
  access_key_id #{node[:ldap389][:access_key_id]}
  secret_access_key #{node[:ldap389][:secret_access_key]}
  owner "root"
  group "root"
  mode 0644
end

execute "tar xvfz /var/lib/dirsrv/slapd-dcaldap01b_varlibdirsrv.tar.gz" do
  cwd "/var/lib/dirsrv"
end

s3_file "/var/lock/dirsrv/slapd-dcaldap01b_varlockdirsrv.tar.gz" do
  source "s3://opsworks-test01/slapd-dcaldap01b_varlockdirsrv.tar.gz"
  access_key_id #{node[:ldap389][:access_key_id]}
  secret_access_key #{node[:ldap389][:secret_access_key]}
  owner "root"
  group "root"
  mode 0644
end

execute "tar xvfz /var/lock/dirsrv/slapd-dcaldap01b_varlockdirsrv.tar.gz" do
  cwd "/var/lock/dirsrv"
end

s3_file "/var/log/dirsrv/slapd-dcaldap01b_varlogdirsrv.tar.gz" do
  source "s3://opsworks-test01/slapd-dcaldap01b_varlogdirsrv.tar.gz"
  access_key_id #{node[:ldap389][:access_key_id]}
  secret_access_key #{node[:ldap389][:secret_access_key]}
  owner "root"
  group "root"
  mode 0644
end

execute "tar xvfz /var/log/dirsrv/slapd-dcaldap01b_varlogdirsrv.tar.gz" do
  cwd "/var/log/dirsrv"
end

include_recipe 'ldap389::service'

service 'dirsrv' do
  action :enable
end

service 'dirsrv' do
  action :stop
end

service 'dirsrv' do
  action :start
end

