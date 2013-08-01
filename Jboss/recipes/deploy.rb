cookbook_file "/root/deploy.sh" do
  source "deploy.sh"
end

script "Run the test script" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
sh deploy.sh
EOH
end
