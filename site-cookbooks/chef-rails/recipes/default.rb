node['chef-rails']['packages'].collect do |pkg|
  package pkg
end

bash "remove default nginx sites" do
  code %{
    sudo rm -f /etc/nginx/sites-available/default
    sudo rm -f /etc/nginx/sites-enabled/default
  }
end

bash "install or update bundle" do
  code "sudo gem install bundle --no-ri --no-rdoc"
end

bash "change owner and group of chef-solo tmp files" do
  code "sudo chown -R #{node[:authorization][:sudo][:users].first}:#{node[:authorization][:sudo][:groups].first} /tmp/chef-solo"
end
