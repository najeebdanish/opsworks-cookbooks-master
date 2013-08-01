cookbook_file "/root/deploy.sh" do
  source "deploy.sh"
end

system("cd /root")
