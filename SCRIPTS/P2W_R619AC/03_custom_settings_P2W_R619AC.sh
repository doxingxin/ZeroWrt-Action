#!/bin/bash
clear

# 使用特定的优化
sed -i 's/-mcpu=generic/-march=armv7-a+neon-vfpv4+crypto/g' include/target.mk
# sed -i 's,kmod-r8168,kmod-r8169,g' target/linux/rockchip/image/armv8.mk

find ./ -name *.orig | xargs rm -f
find ./ -name *.rej | xargs rm -f

# Vermagic
curl -s https://downloads.openwrt.org/releases/24.10.1/targets/ipq40xx/generic/openwrt-24.10.1-ipq40xx-generic.manifest \
| grep "^kernel -" \
| awk '{print $3}' \
| sed -n 's/.*~\([a-f0-9]\+\)-r[0-9]\+/\1/p' > vermagic
sed -i 's#grep '\''=\[ym\]'\'' \$(LINUX_DIR)/\.config\.set | LC_ALL=C sort | \$(MKHASH) md5 > \$(LINUX_DIR)/\.vermagic#cp \$(TOPDIR)/vermagic \$(LINUX_DIR)/.vermagic#g' include/kernel-defaults.mk

# distfeeds.conf
mkdir -p files/etc/opkg
cat > files/etc/opkg/distfeeds.conf <<EOF
src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/arm_cortex-a7_neon-vfpv4/base
src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/arm_cortex-a7_neon-vfpv4/luci
src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/arm_cortex-a7_neon-vfpv4/packages
src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/arm_cortex-a7_neon-vfpv4/routing
src/gz openwrt_telephony https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/packages/arm_cortex-a7_neon-vfpv4/telephony
src/gz openwrt_core https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/24.10.1/targets/ipq40xx/mikrotik/kmods/6.6.86-1-56a439649312685533153310661532b3
EOF

# default-settings
git clone --depth=1 -b aarch64 https://github.com/oppen321/default-settings package/default-settings

# ZeroWrt选项菜单
mkdir -p files/bin
curl -L -o files/bin/ZeroWrt https://git.kejizero.online/zhao/files/raw/branch/main/bin/ZeroWrt
chmod +x files/bin/ZeroWrt
mkdir -p files/root
curl -L -o files/root/version.txt https://git.kejizero.online/zhao/files/raw/branch/main/bin/version.txt
chmod +x files/root/version.txt

exit 0
