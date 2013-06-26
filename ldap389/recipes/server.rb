package '389-ds'

remote_file "/root/s3cmd-1.0.0-4.1.x86_64.rpm" do
  source "s3cmd-1.0.0-4.1.x86_64.rpm"
end

execute 'install s3cmd rpm' do
  cwd '/root/'
  command "rpm -i s3cmd-1.0.0-4.1.x86_64.rpm"
  action :run
  only_if "rpm -qa|grep s3cmd"
end

template '/root/.s3cfg' do
  source 's3cfg.erb'
  backup false
  owner 'root'
  group 'root'
  mode 0600
end

package 's3cmd'

script "Get all 389 files" do
  interpreter "bash"
  user "root"
  cwd "/etc/"
  code <<-EOH
  s3cmd get s3://opsworks-test01/dirsrv_etc.tar.gz
  tar -zxf dirsrv_etc.tar.gz
  cd /usr/lib64
  s3cmd get s3://opsworks-test01/dirsrv_usrlib64.tar.gz
  tar -zxf dirsrv_usrlib64.tar.gz
  cd /var/lib/dirsrv
  s3cmd get s3://opsworks-test01/slapd-dcaldap01b_varlibdirsrv.tar.gz
  tar -zxf slapd-dcaldap01b_varlibdirsrv.tar.gz
  cd /var/lock/dirsrv
  s3cmd get s3://opsworks-test01/slapd-dcaldap01b_varlockdirsrv.tar.gz
  tar -zxf slapd-dcaldap01b_varlockdirsrv.tar.gz
  cd /var/log/dirsrv
  s3cmd get s3://opsworks-test01/slapd-dcaldap01b_varlogdirsrv.tar.gz
  tar -zxf slapd-dcaldap01b_varlogdirsrv.tar.gz
  EOH
end

  
include_recipe 'ldap389::service'

service 'dirsrv' do
  action :enable
end

service 'dirsrv' do
  action :stop
end

# service 'dirsrv' do
#  action :start
# end

