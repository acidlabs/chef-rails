template "#{node[:nginx][:dir]}/conf.d/real_ip.conf" do
  owner "root"
  group "root"
  mode "0644"
  backup false
  notifies :restart, resources(:service => "nginx"), :delayed
end
