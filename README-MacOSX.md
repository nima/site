# Mac OS X Installs
You will want to install the gnu utilities via `brew`: install `sed`, `awk`, and `grep`, and uncomment and configure the function declarations in `~/.siterc` to point those commands to the gnu utilities, not the Mac OS X BSD flavours.

Bash is also too old on Mac OS X, so make sure to override it too by uncommenting and configuring `SITE_SHELL`.

Finally, edit `~/.siterc` and export your PROFILE in there; there is no need to modify your current bash profile.  You can also point various commands such as `awk` and `sed`, and even `bash` itself to other commands in here, so there is no need to change your active PATH for site either.

## Domain Resolution
See http://www.makingitscale.com/2011/fix-for-broken-search-domain-resolution-in-osx-lion.html

* Edit /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
* Add `-AlwaysAppendSearchDomains` parameter to the list in the `ProgramArguments` block
* Run the following commands:
```
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
```
