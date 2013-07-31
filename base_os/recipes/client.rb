############################################################################
## This cookbook will install and setup ldap client, amanda client, 
## and DNS entries for DR automation
############################################################################


package 'pam_ldap'
package 'nss-pam-ldapd'
package 'amanda-client'
package 'expect'

cookbook_file "/root/opsworks_amandarestore" do
  source "opsworks_amandarestore"
end

cookbook_file "/etc/amanda/amanda-client.conf" do
  source "amanda-client.conf"
end

script "Ldap client setup" do
  interpreter "bash"
  user "root"
  cwd "/etc/"
  code <<-EOH
  chmod 600 /root/opsworks_amandarestore
  chown root.root /root/opsworks_amandarestore
  cat /etc/ssh/sshd_config | grep PasswordAuthentication | sed -i "s/PasswordAuthentication/#PasswordAuthentication/g" /etc/ssh/sshd_config
  cat /etc/ssh/sshd_config | grep PasswordAuthentication | sed -i "s/UseDNS/#UseDNS/g" /etc/ssh/sshd_config
  cat /etc/ssh/sshd_config | grep PasswordAuthentication | sed -i "s/PermitRootLogin/#PermitRootLogin/g" /etc/ssh/sshd_config
  echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
  echo "UseDNS no" >> /etc/ssh/sshd_config
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  /etc/init.d/sshd restart
  /etc/init.d/nslcd restart
  count=0
  if [[ `ssh -o StrictHostKeyChecking=no -i opsworks_amandarestore root@23.23.192.84 "ifconfig eth0" | grep "inet addr" | awk -F":" '{print $2}' | awk -F" " '{print $1}'` != "ok" ]] && [[ $count -lt 10 ]] ; then
     sleep 300
	 count=`expr $count + 1`
  fi
  ldapipadd=`ssh -o StrictHostKeyChecking=no -i opsworks_amandarestore root@23.23.192.84 "ifconfig eth0" | grep "inet addr" | awk -F":" '{print $2}' | awk -F" " '{print $1}'`
  echo "nameserver $ldapipadd" > /etc/resolv.conf
  authconfig --enableldap --enableldapauth --ldapserver='ldap://iadbackup01.evolvsuite.local/' --ldapbasedn='dc=evolv,dc=com' --enablelocauthorize --update
  echo "%evolvadmins ALL=(ALL) /bin/su - evolv" >> /etc/sudoers
  echo "%sysadmins        ALL=(ALL)       ALL" >> /etc/sudoers
  echo "%Install       ALL=(ALL)       ALL" >> /etc/sudoers
  groupadd -g 300 evolv
  useradd -g 300 -u 300 -s /bin/bash -m -d /opt/evolv evolv
  echo "$ldapipadd amandabackup amdump" >> /var/lib/amanda/.amandahosts
  chown amandabackup.disk /etc/amanda/amanda-client.conf
  ipadd=`ifconfig eth0 | grep "inet addr" | awk -F":" '{print $2}' | awk -F" " '{print $1}'`
  ssh -o StrictHostKeyChecking=no -i /root/opsworks_amandarestore root@23.23.192.84 "echo \"${ipadd} root amindexd amidxtaped\" >> /var/lib/amanda/.amandahosts"
  EOH
end



