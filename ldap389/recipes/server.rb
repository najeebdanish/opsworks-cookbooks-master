############################################################################
## This cookbook will install and setup 389 Directory server, DNS server,
## and Amanda Backup Server for DR automation
############################################################################


# Install xinetd package needed for amanda-backup_server rpm installation
package 'xinetd'

cookbook_file "/root/amanda-backup_server-3.3.1-1.rhel6.x86_64.rpm" do
  source "amanda-backup_server-3.3.1-1.rhel6.x86_64.rpm"
end

execute 'install amanda-backup-server' do
  cwd '/root/'
  command "rpm -i amanda-backup_server-3.3.1-1.rhel6.x86_64.rpm"
  action :run
end

cookbook_file "/root/opsworks_amandarestore.pub" do
  source "opsworks_amandarestore.pub"
end

# Get the Amanda Server configuration files
cookbook_file "/etc/amanda_IadBackup01.tar.gz" do
  source "amanda_IadBackup01.tar.gz"
end


# Install s3cmd utility
package 's3cmd'

template '/root/.s3cfg' do
  source 's3cfg.erb'
  backup false
  owner 'root'
  group 'root'
  mode 0600
end


# Install bind DNS server
package 'bind'

cookbook_file "/etc/named.conf" do
  source "named.conf"
end

cookbook_file "/etc/bind_dcans01_29JUL13.tar.gz" do
  source "bind_dcans01_29JUL13.tar.gz"
end


# Install 389 Directory Server
package '389-ds'

cookbook_file "/root/389InstallFile.inf" do
  source "389InstallFile.inf"
end


script "Get all needed files and install 389, bind, and Amanda" do
  interpreter "bash"
  user "root"
  cwd "/etc/"
  code <<-EOH
  chown root.named /etc/named.conf
  chmod 640 /etc/named.conf
  tar -zxf bind_dcans01_29JUL13.tar.gz
  /etc/init.d/named restart
  cd /root/
  rm -f /root/ldapserver_ready.txt
  s3cmd get s3://opsworks-test01/dcaldap01.backup1.ldif
  /usr/sbin/setup-ds-admin.pl -s -f 389InstallFile.inf
  /etc/init.d/dirsrv stop
  cd /etc/
  s3cmd get s3://opsworks-test01/dirsrv_etc.tar.gz
  rm -rf dirsrv
  tar -zxf dirsrv_etc.tar.gz
  sed -i "`grep -n -A 5 dna_init /etc/dirsrv/slapd-dcaldap01b/dse.ldif | grep nsslapd-pluginEnabled | awk -F"-" '{print $1}'`s/on/off/" /etc/dirsrv/slapd-dcaldap01b/dse.ldif
  /usr/lib64/dirsrv/slapd-dcaldap01b/ldif2db -i /root/dcaldap01.backup1.ldif -s "dc=evolv,dc=com"
  cd /etc/
  rm -rf amanda/
  tar -zxf amanda_IadBackup01.tar.gz
  /etc/init.d/xinetd restart
  cat /root/opsworks_amandarestore.pub >> /root/.ssh/authorized_keys
  iadbkp=`cat /etc/bind/zones/evolvsuite.local|grep iadbackup01`
  ipadd=`ifconfig eth0 | grep "inet addr" | awk -F":" '{print $2}' | awk -F" " '{print $1}'`
  iadbkpip=`echo $iadbkp | awk -F" " '{print $4}'`
  newiadbkp=`echo $iadbkp | sed "s/$iadbkpip/$ipadd/"`
  sed -i "s/$iadbkp/$newiadbkp/" /etc/bind/zones/evolvsuite.local
  bindserial=`cat /etc/bind/zones/evolvsuite.local | grep Serial | awk -F" " '{print$1}'`
  bindserialnew=`expr $bindserial + 1`
  sed -i "s/$bindserial/$bindserialnew/" /etc/bind/zones/evolvsuite.local
  rndc reload
  echo "nameserver $ipadd" > /etc/resolv.conf
  echo "ok" > /root/ldapserver_ready.txt
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

