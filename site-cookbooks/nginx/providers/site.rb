action :enable do
  unless @nginx_site.enabled
    execute "nginx site #{new_resource.name} enabled" do
      command %{
        ln -nfs #{node[:nginx][:dir]}/sites-available/#{new_resource.name} \
        #{node[:nginx][:dir]}/sites-enabled/#{new_resource.name}
      }
      notifies :reload, resources(:service => "nginx"), :delayed
    end
    @nginx_site.enabled(true)
  end
end

action :disable do
  if @nginx_site.enabled
    execute "nginx site #{new_resource.name} disabled" do
      command %{
        rm -f #{node[:nginx][:dir]}/sites-enabled/#{new_resource.name}
      }
      notifies :reload, resources(:service => "nginx"), :delayed
    end
    @nginx_site.enabled(false)
  end
end

def load_current_resource
  @nginx_site = Chef::Resource::NginxSite.new(new_resource.name)

  @nginx_site.enabled(true) if ::File.exists?(
    "#{node[:nginx][:dir]}/sites-enabled/#{new_resource.name}"
  )
end
