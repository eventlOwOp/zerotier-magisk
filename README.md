# ZeroTier for Magisk - run ZeroTier in the background

<div align="center">

[[中文](https://github.com/eventlOwOp/zerotier-magisk/blob/master/README_ZH.md) | English]

</div>
  
**Run zerotier in the background after booting!**

**No conflicts with other android VPN service!**

## Requirements

1. a version is built with Android NDK Toolchain, supporting api 28 (Android 9.0) and above.

2. another version is build with GCC toolchain, linking to Linux Syscalls statically

Unofficial planet supported; SSO (zeroidc) supported in the version built with GCC for AArch64

AArch64 suppots ARMv8-A and above; Arm version supports ARMv7-A (compiling with `-march=armv7-a`)

## Installation

1. download release from github.
2. install with magisk.
3. modify the config file at `/sdcard/Android/zerotier/network_id.txt` and put your 16-character network id in it.
4. restart and enjoy.

To restart, execute (in root) `sh /data/adb/zerotier/zerotier.sh restart`; An android application to control zerotier (networkid, restart, ...) has been added to the todo list.

### Files

```
/data/adb/zerotier/
 | - run/
 |   | - pipe                   # pipe to service.sh
 |   | - daemon.log             # service.sh log
 |   ` - zerotier.log           # zerotier-one log
 | - home/                      # zerotier-one home directory
 |   ` - ...
 | - lib/
 |   ` - libc++_shared.so       # NDK dynamic library
 | - zerotier.sh                # tool to communicate with service.sh
 | - zerotier-one               # zerotier-one executable
 | - zerotier-cli -> zerotier-one
 ` - zerotier-idtool -> zerotier-one
```

all the scripts and binaries are placed in `/data/adb/zerotier/`.

`zerotier.sh` writes commands to the pipe at `run/pipe` and `service.sh` read from it.

`Usage: sh zerotier.sh {start|stop|restart|join|leave}`

log files are placed in `run`, `daemon.log` for `service.sh` and `zerotier.log` for ZeroTierOne.

### Build binaries yourself

The binaries are built with Android NDK toolchains on Github Action, see `.github/workflow/build.yml` for detailed information.
