require 'resolv'

package '389-ds'

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

