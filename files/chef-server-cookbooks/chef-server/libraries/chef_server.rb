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

require 'mixlib/config'
require 'chef/mash'
require 'chef/json_compat'
require 'chef/mixin/deep_merge'
require 'securerandom'

module ChefServer
  extend(Mixlib::Config)

  # options are "ipv4", "ipv6"
  ip_version "ipv4"

  chef_pedant Mash.new
  estatsd Mash.new
  rabbitmq Mash.new
  chef_solr Mash.new
  chef_expander Mash.new
  erchef Mash.new
  chef_server_webui Mash.new
  lb Mash.new
  postgresql Mash.new
  bookshelf Mash.new
  bootstrap Mash.new
  nginx Mash.new
  user Mash.new
  api_fqdn nil
  node nil
  notification_email nil

  class << self

    # guards against creating secrets on non-bootstrap node
    def generate_hex(chars)
      SecureRandom.hex(chars)
    end

    def generate_secrets(node_name)
      existing_secrets ||= Hash.new
      if File.exists?("/etc/chef-server/chef-server-secrets.json")
        existing_secrets = Chef::JSONCompat.from_json(File.read("/etc/chef-server/chef-server-secrets.json"))
      end
      existing_secrets.each do |k, v|
        v.each do |pk, p|
          ChefServer[k][pk] = p
        end
      end

      ChefServer['rabbitmq']['password'] ||= generate_hex(50)
      ChefServer['chef_server_webui']['cookie_secret'] ||= generate_hex(50)
      ChefServer['postgresql']['sql_password'] ||= generate_hex(50)
      ChefServer['postgresql']['sql_ro_password'] ||= generate_hex(50)
      ChefServer['bookshelf']['access_key_id'] ||= generate_hex(20)
      ChefServer['bookshelf']['secret_access_key'] ||= generate_hex(40)

      if File.directory?("/etc/chef-server")
        File.open("/etc/chef-server/chef-server-secrets.json", "w") do |f|
          f.puts(
            Chef::JSONCompat.to_json_pretty({
              'rabbitmq' => {
                'password' => ChefServer['rabbitmq']['password'],
              },
              'chef_server_webui' => {
                'cookie_secret' => ChefServer['chef_server_webui']['cookie_secret'],
              },
              'postgresql' => {
                'sql_password' => ChefServer['postgresql']['sql_password'],
                'sql_ro_password' => ChefServer['postgresql']['sql_ro_password']
              },
              'bookshelf' => {
                'access_key_id' => ChefServer['bookshelf']['access_key_id'],
                'secret_access_key' => ChefServer['bookshelf']['secret_access_key']
              }
            })
          )
          system("chmod 0600 /etc/chef-server/chef-server-secrets.json")
        end
      end
    end

    def generate_hash
      results = { "chef_server" => {} }
      [
        "chef_pedant",
        "estatsd",
        "rabbitmq",
        "chef_solr",
        "chef_expander",
        "erchef",
        "chef_server_webui",
        "lb",
        "postgresql",
        "nginx",
        "bookshelf",
        "bootstrap", 
        "user"
      ].each do |key|
        rkey = key.gsub('_', '-')
        results['chef_server'][rkey] = ChefServer[key]
      end
      results['chef_server']['notification_email'] = ChefServer['notification_email']

      results
    end

    def gen_api_fqdn
      ChefServer["lb"]["api_fqdn"] ||= ChefServer['api_fqdn']
      ChefServer["lb"]["web_ui_fqdn"] ||= ChefServer['api_fqdn']
      ChefServer["nginx"]["server_name"] ||= ChefServer['api_fqdn']

      # If the user manually set an Nginx URL in the config file all bets are
      # off...we just cross our fingers and hope they constructed the URL
      # correctly! We may want to remove this 'private' config value from the
      # documenation.
      if ChefServer["nginx"]["url"].nil?
        ChefServer["nginx"]["url"] = "https://#{ChefServer['api_fqdn']}"
        if ChefServer["nginx"]["ssl_port"]
          ChefServer["nginx"]["url"] << ":#{ChefServer["nginx"]["ssl_port"]}"
        end
      end

      # The external bookshelf URL should match the external lb
      ChefServer["bookshelf"]["url"] ||= ChefServer["nginx"]["url"]
    end

    def generate_config(node_name)
      generate_secrets(node_name)
      determine_ip_mode
      ChefServer[:api_fqdn] ||= node_name
      gen_api_fqdn
      set_nginx_ip_mode
      generate_hash
    end

    def determine_ip_mode
      # "ipv4", "ipv6", default is ipv4
      case ChefServer["ip_version"]
      when "ipv4", nil
        ChefServer["use_ipv4"] = true
        ChefServer["use_ipv6"] = false
      when "ipv6"
        ChefServer["use_ipv4"] = false
        ChefServer["use_ipv6"] = true
      else # explicitly fail if set to something not recognized
        Chef::Log.fatal("I do not understand the ip mode #{ChefServer.ip_version} - tryr ipv4 or ipv6.")
        exit 55
      end
    end

   def set_nginx_ip_mode
      # If ipv6 mode is on, ensure nginx is in ipv6 mode, but it can also be explicitly
      # enabled if set directly while the rest of the Chef server remains in ipv4 mode
      ChefServer["nginx"]["enable_ipv6"] ||= ChefServer["use_ipv6"]
   end

  end
end
