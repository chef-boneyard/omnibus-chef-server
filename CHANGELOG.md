# Chef Server Changelog

## 11.1.0 (Unreleased)

### Notable changes

* Addition of a ```chef-server-ctl upgrade command```  

    This allows an upgrade of the Chef server in place. It applies necessary SQL changes without having to backup data and install the server from scratch. It is still encouraged that a data backup is performed first, in case something goes wrong.

* Addition of ```nginx['enable_ipv6']``` option  

    Nginx is now included with IPv6 support available. To make use of this, there is an ```nginx['enable_ipv6']``` option that when set to true will cause nginx to handle IPv6 addresses. See the note below on IPv6 support for more on how this flag comes into play.

* Full IPv6 support  

    The Chef server now fully supports IPv6. In the chef-server.rb file, setting ```ip_version "ipv6"``` will turn on IPv6 mode. Note that no equal sign is used when setting this value. This will enable the Chef server to accept IPv6 connections internally and externally. The server will be in dual IPv4/IPv6 mode, so IPv4 connections will continue to function.

  By default the Chef server is in IPv4 mode only. IPv6 mode must  be explicitly enabled.

  Turning on IPv6 mode will automatically set the ```nginx['enable_ipv6']``` flag to true. If IPv6 mode is then turned off, this flag will be set back to false, unless the flag has been explicitly enabled. In the case the flag was explicitly enabled but IPv6 mode is turned off, nginx will continue to accept IPv6 connections, but the internal Chef server components will expect to communicate over IPv4.

  If a value like the bookshelf url is set to a literal IPv6 address, and not a hostname that will be resolved, then the IPv6 address will need to be bracketed (e.g. https://[2001:db8:85a3:8d3:1319:8a2e:370:7348]) or else the Chef server will fail to recognized it as an IPv6 address.

  A change was also made to ensure that all the internal Chef server services listen for IPv6 addresses when this mode is enabled. This involved changing the default listen interface for these services to ```::```, which cause them to listen on IPv6 and IPv4. The IPv4 default interface was also updated to ```0.0.0.0```. This is a change from the previous value of ```127.0.0.1```. If the Chef server is being run in stand alone mode and not in a tiered setup (tiered isn't officially supported, but we know some users run in this mode), the default interface can be set back to ```127.0.0.1``` by setting the following attributes in the chef-server.rb to ```127.0.0.1```.

        bookshelf['listen']
        rabbitmq['node_ip_address']
        chef-solr['ip_address']

  The ```postgresql['listen_address']``` should be set to ```localhost``` instead of ```127.0.0.1```

* Added support for proxy/firewalls.  

    Chef server now supports working through proxies and firewalls by making use of the vhost. The Chef server will inspect the vhost to ensure requests are returned properly through the proxy/firewall.

    If S3 is being used to store cookbooks then bookshelf has two settings, ```bookshelf['s3_url']``` and ```bookshelf['s3_external_url']``` that will need to be set to ensure this continues to function as expected.

    ```bookshelf['s3_url']``` is the S3 url used by the Chef server to communicate with S3. ```bookshelf['s3_external_url']``` is the S3 url that will be returned to clients so they can comminicate with S3. This is necessary since the clients live on the other side of the proxy/firewall from the server.

* Change back to gecode depsolver

  With the 11.0 release, Chef server changed depsolvers from [gecode](http://www.gecode.org/) to an all [erlang depsolver](https://github.com/opscode/depsolver). The idea behind this was to drop the heavy nature of gecode, which has a considerable build time and large binary to ship. However, the experience of switching taught us that our erlang solution was not robust enough to solve all the dependencies that gecode could and that Chef users needed. Therefore with this release the depsolver switches back to using gecode. This switch should be transparent, but in some cases cookbook dependency resolution that was previously failing should work again.

  The change in depsolvers is accomplished through changes to the repo [chef_objects](https://github.com/opscode/chef_objects) and these changes are pulled in by the updated [erchef](https://github.com/opscode/erchef).

* Default RabbitMQ port change

  The default RabbitMQ port has been changed from 5672 to 8672. This was due to a conflict with the default port on RedHat 6 systems. The commit and rationale are can be seen in this [commit message](https://github.com/opscode/omnibus-chef-server/commit/b3bd2c4e20762b5f828953719e8fad56c6b3808e).

  For most users this change should not be an issue, but you may need to adjust the attribute on your systems if you're running in a tiered or HA setup.

* runit update

  This change was actually included in the 11.0.8 release, but if you're updating from an older version you should be aware of this.

  The runit that manages the Chef server processes was updated to no longer have opscode in its path and config names, switching to use chef-server instead. The change was made in this [commit](https://github.com/opscode/omnibus-chef-server/commit/10e571b85db3113818c2b1665e025e86d34e8654).

  While the commit in question attempts to ensure the old process is stopped, in some cases after upgrade orphaned processes have been observed (These are Chef server process that after upgrade instead of being managed by runit are attatched to init (PID 1). The upgrade completes successfully, but the orphaned processes have to be manually killed.

  To avoid this the following steps can be taken to stop all the Chef server processes before doing a package upgrade. You'll need root or sudo access to perform these commands.

  initctl stop opscode-runsvdir

  chef-server-ctl graceful-kill

  pkill -9 -f epmd

  and then follow the upgrade path of your package manager of choice.

  A note on the steps take and the reasons for them. The first step stops the runit process under the old name so it doesn't resurrect any killed processes. Step two stops all the Chef server processes. Step three stops epmd, the Erlang port mapper deamon. Erlang starts a copy of this processes on all systems it runs on. This should actually be managed by runit, but due to an oversight it currently is not.

  With these steps taken a clean upgrade from a pre-11.0.8 install can be performed.

### Bugfixes

* [CHEF-5038](https://tickets.opscode.com/browse/CHEF-5038) Setting NGINX logs to non-standard dir in chef-server doesn't work  
* [CHEF-5031](https://tickets.opscode.com/browse/CHEF-5031) chef-server-ctl reconfigure breaks if chef_pedant or estatsd settings are in chef-server.rb  
* [CHEF-4576](https://tickets.opscode.com/browse/CHEF-4576) Chef Server nginx should be compiled with ipv6 support  
* [CHEF-4511](https://tickets.opscode.com/browse/CHEF-4511) Error in chef_wm/rebar.config  
* [CHEF-4504](https://tickets.opscode.com/browse/CHEF-4504) knife upload interupts with "500 Internal Server Error"  
* [CHEF-4382](https://tickets.opscode.com/browse/CHEF-4382) using a non-default postgresql['port'] in chef-server.rb breaks "chef-server-ctl reconfigure"  
* [CHEF-4346](https://tickets.opscode.com/browse/CHEF-4346) Default Rabbitmq port should be changed to avoid collision with qpidd  
* [CHEF-4235](https://tickets.opscode.com/browse/CHEF-4235) Chef Omnibus cannot be configured with non-default postgres port  
* [CHEF-4188](https://tickets.opscode.com/browse/CHEF-4188) runit embedded in chef-server /etc/inittab entry conflicts with user-installed runit  
* [CHEF-4086](https://tickets.opscode.com/browse/CHEF-4086) getting a latest cookbook list from erchef over split horizon DNS results in great vengeance and furious anger  
* [CHEF-3991](https://tickets.opscode.com/browse/CHEF-3991) Dialyzer fix for estatsd  
* [CHEF-3976](https://tickets.opscode.com/browse/CHEF-3976) chef_objects rejects "provides 'service[foo]'"" in metadata  
* [CHEF-3975](https://tickets.opscode.com/browse/CHEF-3975) Searching for compound attributes in data bags will not yield results  
* [CHEF-3921](https://tickets.opscode.com/browse/CHEF-3921) Missing Dependency causes chef server to consume all the CPU  
* [CHEF-3838](https://tickets.opscode.com/browse/CHEF-3838) RabbitMQ does not start on Oracle or Amazon Linux  
* [CHEF-2380](https://tickets.opscode.com/browse/CHEF-2380) Clients Should be Able to Upload Their Own Public Keys to Chef-Server  
* [CHEF-2245](https://tickets.opscode.com/browse/CHEF-2245) chef-solr jetty request logs go into /var/chef/solr-jetty/logs instead of /var/log/chef  

### Individual Component changes

#### [chef-server-webui 11.1.1](https://github.com/opscode/chef-server-webui/releases/tag/11.1.1)

An update from [chef-server-webui 11.0.10](https://github.com/opscode/chef-server-webui/releases/tag/11.0.10)  
Also see [chef-server-webui 11.1](https://github.com/opscode/chef-server-webui/releases/tag/11.1)

* [CHEF-5242](https://tickets.opscode.com/browse/CHEF-5242) Fix Extra Apostrophe in webui JSON editor  
* [CHEF-5056](https://tickets.opscode.com/browse/CHEF-5056) Upgrade Rails to 3.2.17  
* [CHEF-4858](https://tickets.opscode.com/browse/CHEF-4858) Upgrade chef-server-webui Rails to 3.2.16  
* [CHEF-4757](https://tickets.opscode.com/browse/CHEF-4757) ruby cookbook file in web UI shows up as "Binary file not shown"  
* [CHEF-4403](https://tickets.opscode.com/browse/CHEF-4403) Environment edit screen: Stop json being escaped as html  
* [CHEF-4040](https://tickets.opscode.com/browse/CHEF-4040) Environment existing settings are not displayed correctly when editing environments or nodes via the WebUI  
* [CHEF-4004](https://tickets.opscode.com/browse/CHEF-4004) Select to Close Existing Environment Run List Uses Incorrect Rails Helper  
* [CHEF-3952](https://tickets.opscode.com/browse/CHEF-3952) Cookbook view reports ERROR: undefined method 'close!' for nil:NilClass  
* [CHEF-3951](https://tickets.opscode.com/browse/CHEF-3951) databag item creation not possible  
* [CHEF-3883](https://tickets.opscode.com/browse/CHEF-3883) Chef 11 status page does not list all nodes  
* [CHEF-3267](https://tickets.opscode.com/browse/CHEF-3267) webui status page doesn't respect environment selection  
* [CHEF-2060](https://tickets.opscode.com/browse/CHEF-2060) Auto-complete is enabled in Chef html - /users/login_exec  

The full changeset can be viewed on Github's compare view [here](https://github.com/opscode/chef-server-webui/compare/11.0.10...11.1.1)

#### [omnibus-software a08918d84cb4ae31d4c749167def662350aa6235](https://github.com/opscode/omnibus-software/commits/a08918d84cb4ae31d4c749167def662350aa6235)

An update from commit [1fa82ad5e674b1700b0a28a93fa2801ff6db9290](https://github.com/opscode/omnibus-software/commits/1fa82ad5e674b1700b0a28a93fa2801ff6db9290)

This is a large change that pulls in many updates to the underlying dependencies that Chef Server uses.

The full changeset can be viewed on Github's compare view [here](https://github.com/opscode/omnibus-software/compare/1fa82ad5e674b1700b0a28a93fa2801ff6db9290...a08918d84cb4ae31d4c749167def662350aa6235)


#### [erchef 1.4.0](https://github.com/opscode/erchef/releases/tag/1.4.0)

An update from [erchef 1.2.6](https://github.com/opscode/erchef/releases/tag/1.2.6)

One change of note is the change from [fast_log](https://github.com/opscode/fast-log-erlang) to [lager](https://github.com/basho/lager) as the logger of choice.

This is a large update that pulls in many updates to the underlying erchef dependencies. It is best viewed using Github's compare view seen [here](https://github.com/opscode/erchef/compare/1.2.6...1.4.0)

#### [bookshelf 1.1.3](https://github.com/opscode/bookshelf/releases/tag/1.1.3)

An update from [bookshelf 0.2.8](https://github.com/opscode/bookshelf/releases/tag/0.2.8)

This is a large update that pulls in many improvements to bookshelf. It is best viewed using Github's compare view seen [here](https://github.com/opscode/bookshelf/compare/0.2.8...1.1.3)

#### [Chef 11.12.2](https://github.com/opscode/chef/releases/tag/11.12.2)

The embedded Chef client that ships with the Chef server was bumped from [11.10.4](https://github.com/opscode/chef/releases/tag/11.10.4) to 11.12.2. Github's compare view of the changes can be seen [here](https://github.com/opscode/chef/compare/11.10.4...11.12.2)

#### [chef-pedant 1.0.27](https://github.com/opscode/chef-pedant/releases/tag/1.0.27)

An update form [chef-pedant 1.0.24](https://github.com/opscode/chef-pedant/releases/tag/1.0.24)

This adds some improvements to chef-pedant and updates the tests. Github's compare view of this change can be seen [here](https://github.com/opscode/chef-pedant/compare/1.0.24...1.0.27)

