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

case node["platform_family"]
when "debian"
    case node["platform"]
    when "debian"
        include_recipe "runit::sysvinit"
    else # this catches ubuntu and any random ubuntu-derived debian-ish distros
        include_recipe "runit::upstart"
    end
when "rhel"
    case node["platform"]
    when "amazon", "xenserver"
        # TODO: platform_version check for old distro without upstart
        include_recipe "runit::upstart"
    else
        case node['platform_version']
        when =~ /^5/
            include_recipe "runit::sysvinit"
            #redhat-like distro version 5
        when =~ /^6/
            include_recipe "runit::upstart"
            #redhat-like distro version 6
        when =~ /^7/
            include_recipe "runit::systemd"
            #redhat-like distro version 7
        end
    end
when "fedora"
    case node['platform_version']
    when =~ /^9/
        include_recipe "runit::sysvinit"
        #fedora version 9
     when =~ /^10/
        include_recipe "runit::upstart"
        #fedora version 10
    when =~ /^11/
        include_recipe "runit::upstart"
        #fedora version 11
    when =~ /^12/
        include_recipe "runit::upstart"
        #fedora version 12
    when =~ /^13/
        include_recipe "runit::upstart"
        #fedora version 13
    when =~ /^14/
        include_recipe "runit::upstart"
        #fedora version 14
    else
        include_recipe "runit::systemd"
    end
end

