<div align="center">

<img alt="ZeroTier for Magisk Icon" src="https://github.com/eventlOwOp/zerotier-magisk/blob/master/images/icon.png" width="128" />

# ZeroTier for Magisk

[中文 | [English](https://github.com/eventlOwOp/zerotier-magisk/blob/master/README.md)]

</div>

**将 ZeroTier 保持后台运行**

**不与其他 Android VPN 应用程序冲突**

**使用 Android App 进行控制**

**支持自建 Planet**

## 运行要求

1. 使用 NDK 编译的版本，支持 api 28 (Android 9.0) 及以上的设备

2. 使用 GCC 编译的版本，静态链接到 Linux Syscall，兼容性未知

均支持自建 planet；GCC AArch64 有支持 SSO (zeroidc) 的版本

AArch64 版本支持 ARMv8-A 及以上；Arm 版本均对 ARMv7-A 进行编译 (`-march=armv7-a`)

## 安装

1. 从 Release 处下载 magisk 模块压缩包，并安装
2. 从 Release 处下载控制器的 apk 安装包，并安装
3. 重启
4. 打开控制器 App，输入 16 位 network id 并加入
5. 享用 😋

## 使用

### 自建 Planet

将 `/data/adb/zerotier/home/planet` 替换为自己的 planet 文件即可

### 控制器 App

无需 root 授权

| 功能             | 支持状态 |
| :--------------- | :------- |
| 查看运行状态     | ✅       |
| 启动停止重启     | ✅       |
| 加入离开 network | ✅       |
| 加入离开 planet  | ❎       |

<div>
<img alt="ZeroTier for Magisk Icon" src="https://github.com/eventlOwOp/zerotier-magisk/blob/master/images/app_home.jpg" width="192" />
<img alt="ZeroTier for Magisk Icon" src="https://github.com/eventlOwOp/zerotier-magisk/blob/master/images/app_network.jpg" width="192" />
</div>

### 命令行

查看运行状态，或者启动重启停止，使用 `zerotier.sh`

`Usage: zerotier.sh {start|stop|restart|status}`

ZeroTierOne 支持的所有命令行操作：使用 `zerotier-cli / zerotier-idtool`

（`zerotier-one` 并未导出到 `/system/bin`）

## 目录结构

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

ZeroTier 可执行文件和操作的 Shell 脚本放在 `/data/adb/zerotier/` 下，同时复制到 `/system/bin`（PATH 中）以便于直接执行（除了 `zerotier-one`）

`zerotier.sh` 通过命名管道与 `service.sh` 交互，防止 ZeroTier 作为 Shell 的子进程运行

日志存放在 `/data/adb/zerotier/run` 下，`service.sh` 为 `daemon.log`，ZeroTier 为 `zerotier.log`.

## 自行编译

参考 `.github/workflow/build-{gcc|ndk}.yml`
