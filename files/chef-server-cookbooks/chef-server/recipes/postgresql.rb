#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

postgresql_dir = node['chef_server']['postgresql']['dir']
postgresql_data_dir = node['chef_server']['postgresql']['data_dir']
postgresql_data_dir_symlink = File.join(postgresql_dir, "data")
postgresql_log_dir = node['chef_server']['postgresql']['log_directory']
chef_db_dir = Dir.glob("/opt/chef-server/embedded/service/erchef/lib/chef_db-*").first

user node['chef_server']['postgresql']['username'] do
  system true
  shell node['chef_server']['postgresql']['shell']
  home node['chef_server']['postgresql']['home']
end

directory postgresql_log_dir do
  owner node['chef_server']['postgresql']['username']
  recursive true
end

directory postgresql_dir do
  owner node['chef_server']['postgresql']['username']
  mode "0700"
end

directory postgresql_data_dir do
  owner node['chef_server']['postgresql']['username']
  mode "0700"
  recursive true
end

link postgresql_data_dir_symlink do
  to postgresql_data_dir
  not_if { postgresql_data_dir == postgresql_data_dir_symlink }
end

file File.join(node['chef_server']['postgresql']['home'], ".profile") do
  owner node['chef_server']['postgresql']['username']
  mode "0644"
  content <<-EOH
PATH=#{node['chef_server']['postgresql']['user_path']}
EOH
end

sysv_mem_keys = ["shmmax","shmall"]
sysv_mem = Hash.new
sysv_mem_keys.each do |k|
  sysv_mem[k] = IO.read("/proc/sys/kernel/#{k}").strip.to_i
  if sysv_mem[k] < node['chef_server']['postgresql'][k]
    # Set the sysctl value directly.
    execute "sysctl kernel.#{k}=#{node['chef_server']['postgresql'][k]}"
    shmem_setting = "kernel.#{k} = #{node['chef_server']['postgresql'][k]}"
    shmem_target = if File.directory?("/etc/sysctl.d")
                     "/etc/sysctl.d/90-chef-server-postgresql.conf"
                   else
                     "/etc/sysctl.conf"
                   end
    bash "Save #{k} postgresql setting for next reboot" do
      code "echo '#{shmem_setting}' >> '#{shmem_target}'"
      not_if "fgrep -q '#{shmem_setting}' #{shmem_target}"
    end
  end
end

execute "/opt/chef-server/embedded/bin/initdb -D #{postgresql_data_dir}" do
  user node['chef_server']['postgresql']['username']
  not_if { File.exists?(File.join(postgresql_data_dir, "PG_VERSION")) }
end

postgresql_config = File.join(postgresql_data_dir, "postgresql.conf")

template postgresql_config do
  source "postgresql.conf.erb"
  owner node['chef_server']['postgresql']['username']
  mode "0644"
  variables(node['chef_server']['postgresql'].to_hash)
  notifies :restart, 'service[postgresql]' if OmnibusHelper.should_notify?("postgresql")
end

pg_hba_config = File.join(postgresql_data_dir, "pg_hba.conf")

template pg_hba_config do
  source "pg_hba.conf.erb"
  owner node['chef_server']['postgresql']['username']
  mode "0644"
  variables(node['chef_server']['postgresql'].to_hash)
  notifies :restart, 'service[postgresql]' if OmnibusHelper.should_notify?("postgresql")
end

should_notify = OmnibusHelper.should_notify?("postgresql")

runit_service "postgresql" do
  down node['chef_server']['postgresql']['ha']
  control(['t'])
  options({
    :log_directory => postgresql_log_dir,
    :svlogd_size => node['chef_server']['postgresql']['svlogd_size'],
    :svlogd_num  => node['chef_server']['postgresql']['svlogd_num']
  }.merge(params))
end

if node['chef_server']['bootstrap']['enable']
  execute "/opt/chef-server/bin/chef-server-ctl start postgresql" do
    retries 20
  end
end

# Create the databases
pg_helper = PgHelper.new(node)
pg_port = node['chef_server']['postgresql']['port']
pg_user = node['chef_server']['postgresql']['username']
bin_dir = "/opt/chef-server/embedded/bin"

# Set up a database for the superuser to log into automatically
execute "create #{pg_user} database" do
  command "#{bin_dir}/createdb -T template0 --port #{pg_port} #{pg_user}"
  user pg_user
  not_if { !pg_helper.is_running? || pg_helper.database_exists?(pg_user) }
  retries 30
end

###
# Create the opscode_chef database, migrate it, and create the users we need, and grant them
# privileges.
###
db_name = "opscode_chef"

execute "create #{db_name} database" do
  command "#{bin_dir}/createdb -T template0 --port #{pg_port} -E UTF-8 #{db_name}"
  user pg_user
  not_if { !pg_helper.is_running? || pg_helper.database_exists?(db_name) }
  retries 30
  notifies :run, 'execute[install_schema]', :immediately
end

execute "install_schema" do
  command "sqitch --db-user #{pg_user} deploy --verify" # same as preflight
  cwd "/opt/chef-server/embedded/service/chef-server-schema"
  user pg_user
  action :nothing
end

# Create Database Users

# Save the postgres state, so we can ensure we finish in the same state
# Note that this is evaluated at compile time of the chef run, not runtime
pg_start_state = pg_helper.is_running?

# Start postgres, since it needs to be running to put users in place
execute '/opt/chef-server/bin/chef-server-ctl start postgresql' do
  only_if { !pg_helper.is_running? }
  retries 30
end

ruby_block 'sleep 5' do
  block { sleep 5 }
end

chef_server_pg_user node['chef_server']['postgresql']['sql_user'] do
  password node['chef_server']['postgresql']['sql_password']
  superuser false
end

chef_server_pg_user_table_access node['chef_server']['postgresql']['sql_user'] do
  database 'opscode_chef'
  schema 'public'
  access_profile :write
end

chef_server_pg_user node['chef_server']['postgresql']['sql_ro_user'] do
  password node['chef_server']['postgresql']['sql_ro_password']
  superuser false
end

chef_server_pg_user_table_access node['chef_server']['postgresql']['sql_ro_user'] do
  database 'opscode_chef'
  schema 'public'
  access_profile :read
end

# Return postgres to the state it was in before installing users
execute 'opt/chef-server/bin/chef-server-ctl stop postgresql' do
  not_if { pg_start_state }
  retries 30
end

