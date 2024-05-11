# ZeroTier for Magisk - 后台运行你的 ZeroTier

<div align="center">

[中文 | [English](https://github.com/eventlOwOp/zerotier-magisk/blob/master/README.md)]

</div>

将 ZeroTier 保持后台运行，不与其他 Android VPN 应用程序冲突

## 安装
部分较老内核版本可能不受支持，可以移步 kernel-4.14 分支进行尝试，但是该分支不保证更新

1. 从 Release 下载压缩包
2. 导入 magisk 进行安装
3. 将你的 16 位 ZeroTier network id 写入 `/sdcard/Android/zerotier/network_id.txt`
4. 重启

你可以用 `su` 执行 `/data/adb/zerotier/restart.sh` 来重启，或者干脆重启手机，计划写一个 app 来完成

### 路径

ZeroTier 可执行文件和操作的 Shell 脚本放在 `/data/adb/zerotier/`
`add_ip_rule.sh` is used to make the `main` route table, which zerotier writes its routes to, available.

### 自行编译

仅使用 termux (aarch64) 进行过测试

从 [zerotier/ZeroTierOne](https://www.github.com/zerotier/ZeroTierOne) 下载代码

在 `make-linux.mk` 中对 "aarch64" 或你的架构删除 `ZT_SSO_SUPPORTED=1` 即删除 zeroidc 支持，无需安装 rust 进行编译（目前未找到方法编译 zeroidc ）

`apt-get -y install natpmpc libnpth` 安装依赖库

最后 `make` 编译（多线程使用 `make -j8`）
