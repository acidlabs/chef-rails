actions :enable, :disable

attribute :name,      :kind_of => String,  :name_attribute => true
attribute :enabled,   :default => false

def initialize(*args)
  super
  @action = :enable
end
