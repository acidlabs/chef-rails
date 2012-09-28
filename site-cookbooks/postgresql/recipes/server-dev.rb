#
# Cookbook Name:: postgresql
# Recipe:: server-dev
#

require_recipe "postgresql"

pg_version = node["postgresql"]["version"]
package "postgresql-server-dev-#{pg_version}"