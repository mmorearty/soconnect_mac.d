# soconnect\_mac.d: Watch connect() calls on both IPv4 and IPv6

This is a modified version of the `soconnect_mac.d` script that I first
learned about from [this](http://dtrace.org/blogs/brendan/2011/10/10/top-10-dtrace-scripts-for-mac-os-x/) amazing blog post.

That blog post links to [this](http://dtracebook.com/index.php/Network_Lower_Level_Protocols:soconnect.d#Mac_OS_X) script, but the script only sees connect() calls that were made to IPv4 addresses.

I've modified the script to work for IPv6 as well as IPv4.

## Usage

    sudo soconnect_mac.d

In a few words, this just shows you every `connect()` call made by any process.
See the above-linked blog post for more details.
