# ZeroTier for Magisk - run ZeroTier in the background

<div align="center">

[[中文](https://github.com/eventlOwOp/zerotier-magisk/blob/master/README_ZH.md) | English]

</div>
  
**Run zerotier in the background after booting!**

**No conflicts with other android VPN service!**

## Installation
If you're using a device with an older kernel where this version does not work, you can move to branch kernel-4.14 and installation steps are the same.
but scripts in this branch may be **OUTDATED**.

1. download release from github.
2. install with magisk.
3. modify the config file at `/sdcard/Android/zerotier/network_id.txt` and put your 16-character network id in it.
4. restart and enjoy.

To restart, you can just restart the whole system, or just execute `/data/adb/zerotier/restart.sh`; An android application to control zerotier (networkid, restart, ...) has been added to the todo list.

### Scripts and binaries

all the scripts and binaries are placed in `/data/adb/zerotier/` , you can use termux to run them if needed.
`add_ip_rule.sh` is used to make the `main` route table, which zerotier writes its routes to, available.

### Build binaries yourself

The following steps have only been tested in "Termux" with the package manager "apt".

Note that the zerotier binaries are only built for aarch64, you can build it yourself in "Termux".

Download source files from [zerotier/ZeroTierOne](https://www.github.com/zerotier/ZeroTierOne).

Delete `ZT_SSO_SUPPORTED=1` in `make-linux.mk` for "aarch64" (or your architecture). this will prevent building zeroidc with rust; the author encountered some problems building zeroidc

Install package `natpmpc` using `apt install natpmpc` and update your `libnpth` library using `apt install libnpth`.

At last run `make` or multithreaded `make -j8`.
