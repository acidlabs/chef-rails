actions :add, :remove

attribute :name,                  :kind_of => String,  :name_attribute => true
attribute :server_name,           :kind_of => String
attribute :listen,                :kind_of => Array,  :default => [80]
attribute :public_path,           :kind_of => String
attribute :locations,             :kind_of => Array,   :default => []
attribute :upstreams,             :kind_of => Array,   :default => []
attribute :upstream_keepalive,    :kind_of => Fixnum,  :default => 4
attribute :try_files,             :kind_of => Array,   :default => [] # $uri/index.html $uri "@#{@app.name}"
attribute :client_max_body_size,  :kind_of => String,  :default => "16M"
attribute :keepalive_timeout,     :kind_of => Fixnum,  :default => 10
attribute :custom_directives,     :kind_of => Array,   :default => []
attribute :access_log_format,     :kind_of => String,  :default => "default"

def initialize(*args)
  super
  @action = :add
end
