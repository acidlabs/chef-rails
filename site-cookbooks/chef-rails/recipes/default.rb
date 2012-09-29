node['chef-rails']['packages'].collect do |pkg|
  package pkg
end

bash "install or update bundle" do
  code "sudo gem install bundle --no-ri --no-rdoc"
end
