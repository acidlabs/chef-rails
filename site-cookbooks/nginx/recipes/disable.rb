cookbook_file "#{node[:nginx][:sites_common_dir]}/disable_favicon_logging.conf" do
  action (node[:nginx][:disable_favicon_logging] ? :create : :delete)
  backup false
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :delayed
  owner "root"
end

cookbook_file "#{node[:nginx][:sites_common_dir]}/disable_robots_logging.conf" do
  action (node[:nginx][:disable_robots_logging] ? :create : :delete)
  backup false
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :delayed
  owner "root"
end

cookbook_file "#{node[:nginx][:sites_common_dir]}/disable_hidden.conf" do
  action (node[:nginx][:disable_hidden] ? :create : :delete)
  backup false
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :delayed
  owner "root"
end
