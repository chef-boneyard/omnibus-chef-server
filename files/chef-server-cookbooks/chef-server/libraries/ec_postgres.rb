#
# Copyright:: Copyright 2014 Chef Software, Inc.
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

class EcPostgres
  def self.with_connection(node, database = 'template1')
    require 'pg'
    as_user(node['chef_server']['postgresql']['username']) do
      connection = ::PGconn.open('dbname' => database)
      begin
        yield connection
      ensure
        connection.close
      end
    end
  end

  private

  def self.as_user(user)
    # Find the user in the password database.
    u = (user.is_a? Integer) ? Etc.getpwuid(user) : Etc.getpwnam(user)

    old_process_euid = Process.euid
    Process::UID.eid = u.uid
    begin
      yield
    ensure
      Process::UID.eid = old_process_euid
    end
  end

end
