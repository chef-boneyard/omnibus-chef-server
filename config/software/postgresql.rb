#
# Copyright:: Copyright (c) 2012-2014 Chef Software, Inc.
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

name "postgresql"
default_version "9.2.10"

dependency "zlib"
dependency "openssl"
dependency "libedit"
dependency "ncurses"

version "9.2.14" do
  source :md5 => "ce2e50565983a14995f5dbcd3c35b627"
end

version "9.2.10" do
  source :md5 => "7b81646e2eaf67598d719353bf6ee936"
end

version "9.2.9" do
  source :md5 => "38b0937c86d537d5044c599273066cfc"
end

version "9.2.8" do
  source :md5 => "c5c65a9b45ee53ead0b659be21ca1b97"
end

version "9.3.4" do
  source :md5 => "d0a41f54c377b2d2fab4a003b0dac762"
end

source :url => "http://ftp.postgresql.org/pub/source/v#{version}/postgresql-#{version}.tar.bz2"
relative_path "postgresql-#{version}"

configure_env = {
  "LDFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "CFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "LD_RUN_PATH" => "#{install_dir}/embedded/lib"
}

build do
  command ["./configure",
           "--prefix=#{install_dir}/embedded",
           "--with-libedit-preferred",
           "--with-openssl --with-includes=#{install_dir}/embedded/include",
           "--with-libraries=#{install_dir}/embedded/lib"].join(" "), :env => configure_env
  command "make -j #{max_build_jobs}", :env => {"LD_RUN_PATH" => "#{install_dir}/embedded/lib"}
  command "make install"
end
