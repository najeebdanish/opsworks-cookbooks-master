package '389-ds'

remote_file "/root/s3cmd-1.0.0-4.1.x86_64.rpm" do
  source "s3cmd-1.0.0-4.1.x86_64.rpm"
end

cookbook_file "/root/389InstallFile.inf" do
  source "389InstallFile.inf"
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
package 'xinetd'
package 'bind'

cookbook_file "/root/amanda-backup_server-3.3.1-1.rhel6.x86_64.rpm" do
  source "amanda-backup_server-3.3.1-1.rhel6.x86_64.rpm"
end


execute 'install amanda-backup-server' do
  cwd '/root/'
  command "rpm -i amanda-backup_server-3.3.1-1.rhel6.x86_64.rpm"
  action :run
  #only_if "rpm -qa|grep s3cmd"
end

cookbook_file "/etc/amanda_IadBackup01.tar.gz" do
  source "amanda_IadBackup01.tar.gz"
end


script "Get all 389 files" do
  interpreter "bash"
  user "root"
  cwd "/etc/"
  code <<-EOH
  s3cmd get s3://opsworks-test01/dirsrv_etc.tar.gz
#  tar -zxf dirsrv_etc.tar.gz
  cd /usr/lib64
  s3cmd get s3://opsworks-test01/dirsrv_usrlib64.tar.gz
#  tar -zxf dirsrv_usrlib64.tar.gz
  cd /var/lib/dirsrv
  s3cmd get s3://opsworks-test01/slapd-dcaldap01b_varlibdirsrv.tar.gz
#  tar -zxf slapd-dcaldap01b_varlibdirsrv.tar.gz
  cd /var/lock/dirsrv
  s3cmd get s3://opsworks-test01/slapd-dcaldap01b_varlockdirsrv.tar.gz
#  tar -zxf slapd-dcaldap01b_varlockdirsrv.tar.gz
  cd /var/log/dirsrv
  s3cmd get s3://opsworks-test01/slapd-dcaldap01b_varlogdirsrv.tar.gz
#  tar -zxf slapd-dcaldap01b_varlogdirsrv.tar.gz
  cd /root/
  s3cmd get s3://opsworks-test01/dcaldap01.backup1.ldif
  /usr/sbin/setup-ds-admin.pl -s -f 389InstallFile.inf
  /etc/init.d/dirsrv stop
  cd /etc/
  rm -rf dirsrv
  tar -zxf dirsrv_etc.tar.gz
  sed -i "`grep -n -A 5 dna_init /etc/dirsrv/slapd-dcaldap01b/dse.ldif | grep nsslapd-pluginEnabled | awk -F"-" '{print $1}'`s/on/off/" /etc/dirsrv/slapd-dcaldap01b/dse.ldif
  /usr/lib64/dirsrv/slapd-dcaldap01b/ldif2db -i /root/dcaldap01.backup1.ldif -s "dc=evolv,dc=com"
  cd /etc/
  rm -rf amanda/
  tar -zxf amanda_IadBackup01.tar.gz
  /etc/init.d/xinetd restart
  EOH
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

