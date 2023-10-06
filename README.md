# zerotier-magisk
This magisk module enables you to start zerotier in the background after booting.

## Installation

1. download zipped code file from github.
2. modify zerotier/network and write down your own network id.
3. install and enjoy.

### Scripts and binaries

all the scripts and binaries are placed in `/data/adb/zerotier/` ， you can use termux to run them if needed.

`add_ip_rule.sh` is used to make the `main` route table, which zerotier writes its routes to, available.

### Build binaries yourself

Note that the zerotier binaries are only build for aarch64, you can build it yourself in termux.

Remember to delete `ZT_SSO_SUPPORTED=1` if you don't want to build zeroidc with rust.
