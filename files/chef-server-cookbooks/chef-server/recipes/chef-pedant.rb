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

pedant_dir = node['chef_server']['chef-pedant']['dir']
pedant_etc_dir = File.join(pedant_dir, "etc")
pedant_log_dir = node['chef_server']['chef-pedant']['log_directory']
[
  pedant_dir,
  pedant_etc_dir,
  pedant_log_dir
].each do |dir_name|
  directory dir_name do
    owner node['chef_server']['user']['username']
    mode '0700'
    recursive true
  end
end

pedant_config = File.join(pedant_etc_dir, "pedant_config.rb")

superuser_name = node['chef_server']['chef-server-webui']['web_ui_admin_user_name']
superuser_key = "/etc/chef-server/#{node['chef_server']['chef-server-webui']['web_ui_admin_user_name']}.pem"

helper = OmnibusHelper.new(node)

solr_url = "http://#{helper.vip_for_uri('chef-solr')}"
solr_url << ":#{node['chef_server']['chef-solr']['port']}"

# Snag the first supported protocol version by our ruby installation
ssl_protocols = node['chef_server']['nginx']['ssl_protocols']
supported_versions = OpenSSL::SSL::SSLContext::METHODS
allowed_versions = ssl_protocols.split(/ /).select do |proto|
  supported_versions.include? proto.gsub(".", "_").to_sym
end

# In a healthy installation, we should be able to count on
# at least one shared protocol version. Leaving failure unhandled here,
# since it means that a pedant run is not possible.
ssl_version = allowed_versions.first.gsub(".", "_").to_sym

template pedant_config do
  owner "root"
  group "root"
  mode  "0755"
  variables({
    :api_url  => node['chef_server']['nginx']['url'],
    :solr_url => solr_url,
    :superuser_name => superuser_name,
    :superuser_key => superuser_key,
    :ssl_version => ssl_version
  }.merge(node['chef_server']['chef-pedant'].to_hash))
end
