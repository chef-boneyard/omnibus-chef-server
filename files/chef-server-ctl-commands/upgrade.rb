#
# Copyright:: Copyright (c) 2014 Opscode, Inc.
#
# All Rights Reserved
#

add_command "upgrade", "Upgrade your private chef installation. Add the '--no-op' flag to see what *would* be upgraded", 1 do
  use_why_run_mode = ARGV.include?("--no-op")

  # Our upgrade process is really just a special chef run
  command = ["chef-solo",
             "--config #{base_path}/embedded/cookbooks/solo.rb",
             "--json-attributes #{base_path}/embedded/cookbooks/pre_upgrade_setup.json",
             "--log_level fatal"] # yes, that's an underscore in log_level
  command << "--why-run" if use_why_run_mode
  status = run_command(command.join(" "))
  exit! 1 unless status.success?
  reconfigure(false)
end
