# Chef Server Changelog

## 11.1.0 (Unreleased)

### omnibus-chef-server

TODO: Figure out where the upgrade work goes and calls it out

TODO: Where does the new nginx option go? Add that here?

TODO: What about the updates to bookshelf that were seen? How do those come in and how should that be dealt with in this file?

### chef-server-webui 11.1

TODO: Verify if 3952 is also fixed in this build

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

The full changeset can be viewed on Github's compare view [here](https://github.com/opscode/chef-server-webui/compare/11.0.10...11.1)

### omnibus-software 1938725a5077a8c1fcc352a38c6462f2481b3b91

TODO: The version here will likely change again

An update from revision 1fa82ad5e674b1700b0a28a93fa2801ff6db9290

This is a large change that pulls in many updates to the underlying dependencies that Chef Server uses.

The full changeset can be viewed on Github's compare view [here](https://github.com/opscode/omnibus-software/compare/1fa82ad5e674b1700b0a28a93fa2801ff6db9290...1938725a5077a8c1fcc352a38c6462f2481b3b91)


### erchef 1.3.1

TODO: A new update to erchef needs to be cut to bring in the change from fastlog to lager (does that involve a version bump to 2.0.0 or just a 1.4.0 change?)

An update from erchef 1.2.6

This is a large update that pulls in many updates to the underlying erchef dependencies. It is best viewed using Github's compare view seen [here](https://github.com/opscode/erchef/compare/1.2.6...1.3.1)

