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

case
when File.exists?("/.dockerinit")
  # Inside Docker, assume no init system exists.
  # Instead, just fire off runsvdir and hope it never dies.
  bash "Launch runsvdir in the background for Docker" do
    code "nohup /opt/chef-server/embedded/bin/runsvdir-start >/dev/null &"
    not_if "pgrep -f 'runsvdir -P /opt/chef-server/service'"
  end

when File.directory?("/etc/systemd")
  # We are running under SystemD
  include_recipe "runit::systemd"
when File.directory?("/etc/init")
  # We are running using Upstart
  include_recipe "runit::upstart"
when File.exists?("/etc/inittab")
  # Assume sysv-style init scripts
  include_recipe "runit::sysvinit"
else
  raise "Cannot determine what init system we are using for runit!"
end
