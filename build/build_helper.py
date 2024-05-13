import toml

# Patch ZeroTierOne/rustybits/zeroidc/Cargo.toml

# > +ZeroTierOne/rustybits/zeroidc/Cargo.toml
# [dependencies]
# openssl-sys = {version = ">=0.9", features = ["vendored"]}

cargo_toml_path = "ZeroTierOne/rustybits/zeroidc/Cargo.toml"
cargo_toml = toml.load(cargo_toml_path)
cargo_toml['dependencies']['openssl-sys'] = { 'version': ">=0.9", 'features': ["vendored"] }
with open(cargo_toml_path, 'w') as f:
    toml.dump(cargo_toml, f)

# -------------------------------------------------------------------------------------------------------

# Patch ZeroTierOne/rustybits/zeroidc/.cargo/config.toml

# > +ZeroTierOne/rustybits/zeroidc/.cargo/config.toml
# [target.armv7-unknown-linux-gnueabihf]
# linker = "arm-linux-gnueabihf-gcc"
# rustflags = ["-C", "target-feature=+crt-static"]
# [target.aarch64-unknown-linux-gnu]
# linker = "aarch64-linux-gnu-gcc"
# rustflags = ["-C", "target-feature=+crt-static"]

config_toml_path = "ZeroTierOne/rustybits/zeroidc/.cargo/config.toml"
config_toml = toml.load(config_toml_path)
config_toml['target']['armv7-unknown-linux-gnueabihf'] = { "linker": "arm-linux-gnueabihf-gcc" }
config_toml['target']['aarch64-unknown-linux-gnu'] = { "linker": "aarch64-linux-gnu-gcc" }
with open(config_toml_path, 'w') as f:
    toml.dump(config_toml, f)

# -------------------------------------------------------------------------------------------------------

# Patch make-linux.mk

make_linux_path = 'ZeroTierOne/make-linux.mk'
with open(make_linux_path, 'r') as file: 
    data = file.read() 
    patch_aarch64 = data.replace(
                        '$(ZT_CARGO_FLAGS)', '$(ZT_CARGO_FLAGS) --target aarch64-unknown-linux-gnu --quiet'
                    ).replace(
                        'rustybits/target/release/libzeroidc.a', 'rustybits/target/aarch64-unknown-linux-gnu/release/libzeroidc.a'
                    )
    patch_arm = data.replace(
                        "$(shell $(CC) -dumpmachine | cut -d '-' -f 1)", 'armhf'
                    ).replace(
                        'override CFLAGS+=-mfloat-abi=hard -march=armv6zk -marm -mfpu=vfp -mno-unaligned-access -mtp=cp15 -mcpu=arm1176jzf-s',
                        'override CFLAGS+=-mfloat-abi=hard -march=armv7-a -marm -mfpu=vfp'
                    ).replace(
                        'override CXXFLAGS+=-mfloat-abi=hard -march=armv6zk -marm -mfpu=vfp -fexceptions -mno-unaligned-access -mtp=cp15 -mcpu=arm1176jzf-s',
                        'override CFLAGS+=-mfloat-abi=hard -march=armv7-a -marm -mfpu=vfp -fexceptions'
                    )
    patch_arm_ndk = data.replace(
                        "$(shell $(CC) -dumpmachine | cut -d '-' -f 1)", 'armhf'
                    ).replace(
                        'override CFLAGS+=-mfloat-abi=hard -march=armv6zk -marm -mfpu=vfp -mno-unaligned-access -mtp=cp15 -mcpu=arm1176jzf-s',
                        'override CFLAGS+=-mfloat-abi=hard -march=armv7-a -marm -mfpu=vfp'
                    ).replace(
                        'override CXXFLAGS+=-mfloat-abi=hard -march=armv6zk -marm -mfpu=vfp -fexceptions -mno-unaligned-access -mtp=cp15 -mcpu=arm1176jzf-s',
                        'override CFLAGS+=-mfloat-abi=hard -march=armv7-a -marm -mfpu=vfp -fexceptions'
                    )
    
    with open(make_linux_path + '.aarch64', 'w') as file:
        file.write(patch_aarch64)
    with open(make_linux_path + '.arm', 'w') as file:
        file.write(patch_arm)
    with open(make_linux_path + '.arm.ndk', 'w') as file:
        file.write(patch_arm_ndk)

# Patch ZeroTierOne/osdep/OSUtils.cpp

osutil_path = 'ZeroTierOne/osdep/OSUtils.cpp'
with open(osutil_path, 'r') as file: 
    data = file.read().replace(
                        '/var/lib/zerotier-one', '/data/adb/zerotier/home'
                    )
with open(osutil_path, 'w') as file:
    file.write(data)