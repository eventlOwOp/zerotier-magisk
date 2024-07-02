<div align="center">

<img alt="ZeroTier for Magisk Icon" src="https://github.com/eventlOwOp/zerotier-magisk/blob/master/images/icon.png" width="128" />

# ZeroTier for Magisk

[[中文](https://github.com/eventlOwOp/zerotier-magisk/blob/master/README_ZH.md) | English]

</div>
  
**Run zerotier in the background after booting!**

**No conflicts with other Android VPN service!**

**Use Android App to control ZeroTier**

**Support for Private Root Servers**

## Requirements

1. a version is built with Android NDK Toolchain, supporting api 28 (Android 9.0) and above.

2. another version is build with GCC toolchain, linking to Linux Syscalls statically

Unofficial planet supported; SSO (zeroidc) supported in the version built with GCC for AArch64

AArch64 suppots ARMv8-A and above; Arm version supports ARMv7-A (compiling with `-march=armv7-a`)

## Installation

1. Download magisk module zip file from github release; install.
2. Download controller app apk file from github release; install.
3. Reboot your phone.
4. Open controller app; enter your 16-character network id; join.
5. Enjoy 😋

## Usage

### Use Private Root Servers

Replace `/data/adb/zerotier/home/planet` with your own `planet` file.

### Controller App

Does not need root privilege

| Feature            | Supported? |
| :----------------- | :--------- |
| status             | ✅         |
| start/stop         | ✅         |
| join/leave network | ✅         |
| join/leave planet  | ❎         |

<div>
<img alt="ZeroTier for Magisk Icon" src="https://github.com/eventlOwOp/zerotier-magisk/blob/master/images/app_home.jpg" width="192" />
<img alt="ZeroTier for Magisk Icon" src="https://github.com/eventlOwOp/zerotier-magisk/blob/master/images/app_network.jpg" width="192" />
</div>

### Command line tools

Use `zerotier.sh` to start/stop or inspect status.

`Usage: zerotier.sh {start|stop|restart|status}`

Use `zerotier-cli / zerotier-idtool` for ZeroTierOne command line operations.

(`zerotier-one` not copied to `/system/bin`)

## Files

```
/data/adb/zerotier
├── home                                    # zerotier-one home directory
│   ├── authtoken.secret                    # zerotier-one http interface authtoken
│   ├── zerotier-one.pid                    # zerotier-one pid
│   ├── zerotier-one.port                   # zerotier-one port
│   └── ...
├── lib                                     # only in NDK compiled module
│   └── libc++_shared.so                    # NDK dynamic library
├── run
│   ├── daemon.log                          # service.sh log
│   ├── pipe                                # named pipe to interact with service.sh
│   ├── zerotier.log                        # zerotier-one log
│   └── ...
├── zerotier-cli -> zerotier-one            # zerotier-one command line interface
├── zerotier-idtool -> zerotier-one         # zerotier-one id tool
├── zerotier-one                            # zerotier-one executable
└── zerotier.sh
```

all the scripts and binaries are placed in `/data/adb/zerotier/`, and all copied to `/system/bin` (in PATH) to be executed directly (except `zerotier-one`)

`zerotier.sh` uses named pipe to communicate with `service.sh`, preventing ZeroTier to start as a subprocess of Shell.

log files are placed in `run`, `daemon.log` for `service.sh` and `zerotier.log` for ZeroTierOne.

## Build binaries yourself

refer to `.github/workflow/build-{gcc|ndk}.yml` for detailed information.
