source :rubygems

omnibus_ruby_local_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "omnibus-ruby"))
omnibus_software_local_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "omnibus-software"))

#gem "omnibus", :path => omnibus_ruby_local_path
gem "omnibus", :git => "git://github.com/opscode/omnibus-ruby.git", :branch => '6fa5ab234f31fd2438bf2a00644039941fc725f5'

#gem "omnibus-software", :path => omnibus_software_local_path
gem "omnibus-software", :git => "git://github.com/opscode/omnibus-software.git", :branch => 'osc-11.0.6-1'

group :development do
  gem "vagrant", "~> 1.0"
end
