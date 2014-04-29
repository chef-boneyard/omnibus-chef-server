# Brings up an existing database for sqitch. We assume you installed the schema
# via omnibus. If this does not work, it would be better to use knife to backup
# the chef server and then restore it after installing the new version of the chef-server.
# We don't expect this to be needed in the future, since Chef Server 11.1+ will have
# sqitch-managed databases.

pg_helper = PgHelper.new(node)
pg_user  = pg_helper.db_user
cookbook = run_context.cookbook_collection['chef-server']
sql_file = cookbook.preferred_filename_on_disk_location(node, :files, 'sql/widen-cookbook-version.sql', nil)

# We need to kill epmd. Erlang will lazy start it when it is needed.
execute 'pkill -9 -f epmd'

# Make sure postgresql is running so we can check the db schema on file.
execute '/opt/chef-server/bin/chef-server-ctl start postgresql' do
  retries 20
end

ruby_block "check-for-sqitch" do
  block { } # no op
  only_if { pg_helper.is_running? && !pg_helper.managed_by_sqitch? }
  notifies :run, "execute[apply-widen-cookbook-version]", :immediately
end

execute 'apply-widen-cookbook-version' do
  command "psql -U #{pg_user} -d opscode_chef < #{sql_file}"
  user pg_user
  action :nothing
  notifies :run, "execute[sqitchfy_database]", :immediately
end

execute 'sqitchfy_database' do
  command "sqitch --db-user #{pg_user} deploy --log-only --to-target @1.0.0"
  cwd '/opt/chef-server/embedded/service/chef-server-schema'
  user pg_user
  action :nothing
  notifies :run, "execute[migrate_database]", :immediately
end

execute "migrate_database" do
  command "sqitch --db-user #{pg_user} deploy --verify"
  cwd "/opt/chef-server/embedded/service/chef-server-schema"
  user pg_user
  action :nothing
end
