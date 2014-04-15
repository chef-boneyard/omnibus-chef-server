#
# Cookbook Name:: runit
# Recipe:: default
#
# Copyright 2008-2010, Opscode, Inc.
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

cookbook_file "/etc/systemd/system/chef-server-runsvdir.service" do
  owner "root"
  group "root"
  mode "0644"
  source "chef-server-runsvdir.service"
  notifies :run, "execute[systemctl enable chef-server-runsvdir.service]", :immediately
end

execute "systemctl enable chef-server-runsvdir.service" do
  action :nothing
  retries 30
end

execute "systemctl start chef-server-runsvdir.service" do
  retries 30
end
