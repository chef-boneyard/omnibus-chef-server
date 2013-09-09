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

erchef_dir = node['chef_server']['erchef']['dir']
erchef_etc_dir = File.join(erchef_dir, "etc")
erchef_log_dir = node['chef_server']['erchef']['log_directory']
erchef_sasl_log_dir = File.join(erchef_log_dir, "sasl")
[
  erchef_dir,
  erchef_etc_dir,
  erchef_log_dir,
  erchef_sasl_log_dir
].each do |dir_name|
  directory dir_name do
    owner node['chef_server']['user']['username']
    mode '0700'
    recursive true
  end
end

link "/opt/chef-server/embedded/service/erchef/log" do
  to erchef_log_dir
end

template "/opt/chef-server/embedded/service/erchef/bin/erchef" do
  source "erchef.erb"
  owner "root"
  group "root"
  mode "0755"
  variables(node['chef_server']['erchef'].to_hash)
  notifies :restart, 'service[erchef]' if OmnibusHelper.should_notify?("erchef")
end

erchef_config = File.join(erchef_etc_dir, "app.config")

template erchef_config do
  source "erchef.config.erb"
  mode "644"
  variables(node['chef_server']['erchef'].to_hash)
  notifies :run, 'execute[remove_erchef_siz_files]', :immediately
  notifies :restart, 'service[erchef]' if OmnibusHelper.should_notify?("erchef")
end

# Erchef still ultimately uses disk_log [1] for request logging, and if
# you change the log file sizing in the configuration **without also
# issuing a call to disk_log:change_size/2, Erchef won't start.
#
# Since we currently don't perform live upgrades, we can fake this by
# removing the *.siz files, which is where disk_log looks to determine
# what size the log files should be in the first place.  If they're
# not there, then we just use whatever size is listed in the
# configuration.
#
# [1]: http://erlang.org/doc/man/disk_log.html
execute "remove_erchef_siz_files" do
  command "rm -f *.siz"
  cwd erchef_log_dir
  action :nothing
end

link "/opt/chef-server/embedded/service/erchef/etc/app.config" do
  to erchef_config
end

runit_service "erchef" do
  down node['chef_server']['erchef']['ha']
  options({
    :log_directory => erchef_log_dir,
    :svlogd_size => node['chef_server']['erchef']['svlogd_size'],
    :svlogd_num  => node['chef_server']['erchef']['svlogd_num']
  }.merge(params))
end

if node['chef_server']['bootstrap']['enable']
  execute "/opt/chef-server/bin/chef-server-ctl start erchef" do
    retries 20
  end
end
