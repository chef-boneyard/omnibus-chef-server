name "chef-server-schema"
default_version "1.0.4"

source :git => "https://github.com/chef/chef-server-schema.git"

dependency "sqitch"

build do
  command "mkdir -p #{install_dir}/embedded/service/#{name}"
  command "#{install_dir}/embedded/bin/rsync -a --delete --exclude=.git/*** --exclude=.gitignore ./ #{install_dir}/embedded/service/#{name}/"
end
