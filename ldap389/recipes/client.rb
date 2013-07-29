package 'pam_ldap'
package 'nss-pam-ldapd'
package 'amanda-client'

script "Ldap client setup" do
  interpreter "bash"
  user "root"
  cwd "/etc/"
  code <<-EOH
  cat /etc/ssh/sshd_config | grep PasswordAuthentication | sed -i "s/PasswordAuthentication/#PasswordAuthentication/g" /etc/ssh/sshd_config
  cat /etc/ssh/sshd_config | grep PasswordAuthentication | sed -i "s/UseDNS/#UseDNS/g" /etc/ssh/sshd_config
  echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
  echo "UseDNS no" >> /etc/ssh/sshd_config
  /etc/init.d/sshd restart
  /etc/init.d/nslcd restart
  authconfig --enableldap --enableldapauth --ldapserver='ldap://10.96.189.128/' --ldapbasedn='dc=evolv,dc=com' --enablelocauthorize --update
  echo "%evolvadmins ALL=(ALL) /bin/su - evolv" >> /etc/sudoers
  echo "%sysadmins        ALL=(ALL)       ALL" >> /etc/sudoers
  echo "%Install       ALL=(ALL)       ALL" >> /etc/sudoers
  echo "nameserver 10.96.189.128" >> /etc/resolv.conf
  groupadd -g 300 evolv
  useradd -g 300 -u 300 -s /bin/bash -m -d /opt/evolv evolv
  EOH
end


