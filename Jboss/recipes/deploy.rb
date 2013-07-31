
cookbook_file "/root/deploy.sh" do
  source "deploy.sh"
end

exec("cd /root")
exec("sh deploy.sh")
