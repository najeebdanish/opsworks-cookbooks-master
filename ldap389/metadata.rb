maintainer        "Palisado"
license           "Apache 2.0"
description       "Installs and configures 389 Directory Server"
version           "0.1"
recipe            "ldap389::client", "Installs 389 client"
recipe            "ldap389::server", "Installs 389 server"

['centos','redhat','fedora','amazon','debian','ubuntu'].each do |os|
  supports os
end
