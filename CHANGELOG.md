# Chef Server Changelog

## 11.1.0 (Unreleased)

### Notable changes

Addition of a chef-server-ctl upgrade command  
This allows an upgrade of the Chef server in place. It applies necessary sql changes without having to backup data and install the server from scratch. It is still encouraged that a data backup is performed first, incase something goes wrong.

Addition of nginx[enable_ipv6] option  
nginx is now included with IPv6 support available. To make use of this, there is an enable_ipv6 option that when set to true will cause nginx to handle IPv6 addresses.

Added support for proxy/firewalls.  
Chef server now supports working through proxies and firewalls by making use of the set vhost by default. If s3 is being used to store cookbooks bookshelf has two settings, s3_url and s3_external_url that will need to be set.

### Bugfixes

[CHEF-5038] Setting NGINX logs to non-standard dir in chef-server doesn't work  
[CHEF-5031] chef-server-ctl reconfigure breaks if chef_pedant or estatsd settings are in chef-server.rb  
[CHEF-4576] Chef Server nginx should be compiled with ipv6 support  
[CHEF-4511] Error in chef_wm/rebar.config  
[CHEF-4504] knife upload interupts with "500 Internal Server Error"  
[CHEF-4382] using a non-default postgresql['port'] in chef-server.rb breaks "chef-server-ctl reconfigure"  
[CHEF-4346] Default Rabbitmq port should be changed to avoid collision with qpidd  
[CHEF-4235] Chef Omnibus cannot be configured with non-default postgres port  
[CHEF-4188] runit embedded in chef-server /etc/inittab entry conflicts with user-installed runit  
[CHEF-4086] getting a latest cookbook list from erchef over split horizon DNS results in great vengeance and furious anger  
[CHEF-3991] Dialyzer fix for estatsd  
[CHEF-3976] chef_objects rejects "provides 'service[foo]'"" in metadata  
[CHEF-3975] Searching for compound attributes in data bags will not yield results  
[CHEF-3952] Cookbook view reports ERROR: undefined method 'close!' for nil:NilClass  
[CHEF-3951] databag item creation not possible  
[CHEF-3921] Missing Dependency causes chef server to consume all the CPU  
[CHEF-3838] RabbitMQ does not start on Oracle or Amazon Linux  
[CHEF-2380] Clients Should be Able to Upload Their Own Public Keys to Chef-Server  
[CHEF-2245] chef-solr jetty request logs go into /var/chef/solr-jetty/logs instead of /var/log/chef  

### chef-server-webui 11.1

An update from chef-server-webui 11.0.10

[CHEF-5056] Upgrade Rails to 3.2.17  
[CHEF-4858] Upgrade chef-server-webui Rails to 3.2.16  
[CHEF-4757] ruby cookbook file in web UI shows up as "Binary file not shown"  
[CHEF-4403] Environment edit screen: Stop json being escaped as html  
[CHEF-4040] Environment existing settings are not displayed correctly when
            editing environments or nodes via the WebUI  
[CHEF-4004] Select to Close Existing Environment Run List Uses Incorrect Rails
            Helper  
[CHEF-3951] databag item creation not possible  
[CHEF-3883] Chef 11 status page does not list all nodes  
[CHEF-3267] webui status page doesn't respect environment selection  
[CHEF-2060] Auto-complete is enabled in Chef html - /users/login_exec  

The full changeset can be viewed on Github's compare view [here](https://github.com/opscode/chef-server-webui/compare/11.0.10...11.1)

### omnibus-software 32e32984bbd180375f0418fee6da1a991227b1fa

An update from revision 1fa82ad5e674b1700b0a28a93fa2801ff6db9290

This is a large change that pulls in many updates to the underlying dependencies that Chef Server uses.

The full changeset can be viewed on Github's compare view [here](https://github.com/opscode/omnibus-software/compare/1fa82ad5e674b1700b0a28a93fa2801ff6db9290...32e32984bbd180375f0418fee6da1a991227b1fa)


### erchef 1.4.0

An update from erchef 1.2.6

One change of note is the change from fastlog to lager as the logger of choice.

This is a large update that pulls in many updates to the underlying erchef dependencies. It is best viewed using Github's compare view seen [here](https://github.com/opscode/erchef/compare/1.2.6...1.4.0)

