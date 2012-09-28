template "#{node[:nginx][:dir]}/conf.d/proxy.conf" do
  cookbook "nginx"
  source "global.proxy.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :delayed
end
