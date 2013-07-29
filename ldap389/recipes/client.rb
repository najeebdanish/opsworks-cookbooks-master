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
  sleep 600
  chmod 600 /root/opsworks_amandarestore
  chown root.root /root/opsworks_amandarestore
  cat /etc/ssh/sshd_config | grep PasswordAuthentication | sed -i "s/PasswordAuthentication/#PasswordAuthentication/g" /etc/ssh/sshd_config
  cat /etc/ssh/sshd_config | grep PasswordAuthentication | sed -i "s/UseDNS/#UseDNS/g" /etc/ssh/sshd_config
  echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
  echo "UseDNS no" >> /etc/ssh/sshd_config
  /etc/init.d/sshd restart
  /etc/init.d/nslcd restart
  authconfig --enableldap --enableldapauth --ldapserver='ldap://ldapserver1/' --ldapbasedn='dc=evolv,dc=com' --enablelocauthorize --update
  echo "%evolvadmins ALL=(ALL) /bin/su - evolv" >> /etc/sudoers
  echo "%sysadmins        ALL=(ALL)       ALL" >> /etc/sudoers
  echo "%Install       ALL=(ALL)       ALL" >> /etc/sudoers
  dnsip=`ping -c 1 ldapserver1 | grep icmp | awk -F"(" '{print$2}' | awk -F")" '{print $1}'`
  echo "nameserver $dnsip" >> /etc/resolv.conf
  groupadd -g 300 evolv
  useradd -g 300 -u 300 -s /bin/bash -m -d /opt/evolv evolv
  echo "iadbackup01.evolvsuite.local amandabackup amdump" >> /var/lib/amanda/.amandahosts
  chown amandabackup.disk /etc/amanda/amanda-client.conf
  ipadd=`ifconfig eth0 | grep "inet addr" | awk -F":" '{print $2}' | awk -F" " '{print $1}'`
  ssh -i /root/opsworks_amandarestore root@ldapserver1 "echo \"${ipadd} root amindexd amidxtaped\" >> /var/lib/amanda/.amandahosts"
  EOH
end



