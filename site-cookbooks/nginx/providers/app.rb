action :add do
  service "nginx"

  template "#{node[:nginx][:dir]}/sites-available/#{new_resource.name}" do
    cookbook "nginx"
    source "proxy.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :app => new_resource
    )
    notifies :reload, resources(:service => "nginx"), :delayed
  end

  nginx_site new_resource.name
end

action :remove do
  nginx_site new_resource.name do
    action :disable
  end

  file "#{node[:nginx][:dir]}/sites-available/#{new_resource.name}" do
    action :delete
  end

  bash "delete all nginx logs for #{new_resource.name}" do
    code "rm -f #{node[:nginx][:log_dir]}/#{new_resource.name}*"
  end
end
