template "#{node[:nginx][:dir]}/conf.d/ssl.conf" do
  cookbook "nginx"
  source "global.ssl.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :delayed
end
