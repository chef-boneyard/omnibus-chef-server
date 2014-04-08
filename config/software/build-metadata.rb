# Copyright:: Copyright (c) 2014 Chef Software, Inc.
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
# @author :: Ho-Sheng Hsiao <hosh@getchef.com>
# @description :: This generates a build-metadata.json file into the deb

name 'build-metadata'
description "generates a build metadata file"
always_build true

build do
  # This is a dirty kludge. This pulls plaform build information from
  # the `project` object. These accesses private functions, and are likely
  # to change. The real fix is to update omnibus-ruby and expose some
  # official methods. Better yet, separate out the data in Project#render_me
  # from the file writing function.
  block do
    _platform, _platform_version, _arch = project.send(:platform_tuple)
    metadata = {
      platform:         _platform,
      platform_version: _platform_version,
      arch:             _arch,
      version:          project.build_version
    }
    File.open("#{install_dir}/build-metadata.json", 'w') do |f|
      f.print(JSON.pretty_generate(metadata))
    end
  end
end
