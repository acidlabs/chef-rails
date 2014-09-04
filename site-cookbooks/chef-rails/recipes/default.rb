node['chef-rails']['packages'].collect do |pkg|
  package pkg
end
