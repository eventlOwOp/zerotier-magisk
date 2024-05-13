# ZeroTier for Magisk - 后台运行你的 ZeroTier

<div align="center">

[中文 | [English](https://github.com/eventlOwOp/zerotier-magisk/blob/master/README.md)]

</div>

将 ZeroTier 保持后台运行，不与其他 Android VPN 应用程序冲突

## 运行要求

1. 使用 NDK 编译的版本，支持 api 28 (Android 9.0) 及以上的设备

2. 使用 GCC 编译的版本，静态链接到 Linux Syscall，兼容性未知

均支持自建 planet；GCC AArch64 有支持 SSO (zeroidc) 的版本

AArch64 版本支持 ARMv8-A 及以上；Arm 版本均对 ARMv7-A 进行编译 (`-march=armv7-a`)

## 安装

1. 从 Release 下载压缩包
2. 导入 magisk 进行安装
3. 将你的 16 位 ZeroTier network id 写入 `/sdcard/Android/zerotier/network_id.txt`
4. 重启

你可以用 `su` 执行 `sh /data/adb/zerotier/zerotier.sh restart` 来重启，或者干脆重启手机，计划写一个 app 来完成

### 文件

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

ZeroTier 可执行文件和操作的 Shell 脚本放在 `/data/adb/zerotier/`

`zerotier.sh` 向管道 `run/pipe` 写入， `service.sh` 读取管道，然后进行操作

`Usage: sh zerotier.sh {start|stop|restart|join|leave}`

log files are placed in `run`, `daemon.log` for `service.sh` and `zerotier.log` for ZeroTierOne.

### 自行编译

使用 NDK，参考 `.github/workflow/build.yml`
