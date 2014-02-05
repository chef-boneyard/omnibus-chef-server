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

name "erchef"
#version "1.2.24"
version "mm/prep-11.1-release"

dependency "erlang"
dependency "rsync"
dependency "curl"
dependency "gecode"

source :git => "git://github.com/opscode/erchef"

relative_path "erchef"

env = {
  "PATH" => "#{install_dir}/embedded/bin:#{ENV["PATH"]}",
  "LDFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "CFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "LD_RUN_PATH" => "#{install_dir}/embedded/lib"
}

build do
  command "make distclean", :env => env
  ## RUBY DEPSOLVER - REMOVE BUNDLER_BUSTER FOR ROLLBACK ##
  # Omnibus is run from within bunlder. Applications running from within
  # bundler have environment variables set that effect the sub-execution
  # of ruby code, especially instances of bundler. To install the ruby
  # based depsolver, the oc_erchef Makefile executes bundler to package
  # the application and its dependencies. For this not to effect the
  # ruby environment from which we run omnbius, we must clear the
  # currently set bundler environment variables. BUNDLER BUSTER does this.
  command "make rel", :env => env.merge(Omnibus::Builder::BUNDLER_BUSTER)

  command "mkdir -p #{install_dir}/embedded/service/erchef"
  command "#{install_dir}/embedded/bin/rsync -a --delete --exclude=.git/*** --exclude=.gitignore ./rel/erchef/ #{install_dir}/embedded/service/erchef/"
  command "rm -rf #{install_dir}/embedded/service/erchef/log"
end
