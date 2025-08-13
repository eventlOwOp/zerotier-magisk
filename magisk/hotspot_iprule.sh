#!/system/bin/sh
ZTROOT=/data/adb/zerotier
ACTION="$1"  # 参数：add 或 del


# 获取接口/IP
get_zt_iface() {
    ip link | awk -F': ' '/ zt[[:alnum:]]+/ {print $2; exit}'
}
get_hot_iface() {
    ip link | awk -F': ' '/(^| )(swlan[[:alnum:]_]*|softap[[:alnum:]_]*|ap[[:alnum:]_]*)\:/ {print $2; exit}' | cut -d'@' -f1 | head -n1
}
get_hot_cidr() {
    ip -4 addr show dev "$1" | awk '/inet /{print $2; exit}'
}


set_nat_rules() {
    ZT_IFACE=$(get_zt_iface)
    HOT_IFACE=$(get_hot_iface)
    HOT_CIDR=$(get_hot_cidr "$HOT_IFACE")

    [ -n "$ZT_IFACE" ] && [ -n "$HOT_CIDR" ] || return 1

    # 创建自定义链（如不存在）
    iptables -t nat -N ZT_NAT 2>/dev/null
    iptables -N ZT_FWD 2>/dev/null

    # 确保主链首条跳转到自定义链
    iptables -t nat -C POSTROUTING -j ZT_NAT 2>/dev/null || \
        iptables -t nat -I POSTROUTING 1 -j ZT_NAT
    iptables -C FORWARD -j ZT_FWD 2>/dev/null || \
        iptables -I FORWARD 1 -j ZT_FWD

    # 添加规则
    iptables -t nat -A ZT_NAT -s "$HOT_CIDR" -o "$ZT_IFACE" -j MASQUERADE
    iptables -A ZT_FWD -i "$HOT_IFACE" -o "$ZT_IFACE" \
        -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
    iptables -A ZT_FWD -i "$ZT_IFACE" -o "$HOT_IFACE" \
        -m state --state ESTABLISHED,RELATED -j ACCEPT

    echo "[ZT-NAT] Rules applied: $HOT_IFACE $HOT_CIDR ↔ $ZT_IFACE" >> "$ZTROOT/run/daemon.log"
}

flush_rules() {
    iptables -t nat -F ZT_NAT 2>/dev/null
    iptables -F ZT_FWD 2>/dev/null
    echo "[ZT-NAT] Custom chains flushed." >> "$ZTROOT/run/daemon.log"
}

case "$ACTION" in
    add)
        set_nat_rules
        echo "[ZT-NAT] Guard started." >> "$ZTROOT/run/daemon.log"
        ip monitor link addr | while read -r _; do
            flush_rules
            set_nat_rules
        done
        ;;
    del)
        flush_rules
        ;;
    *)
        echo "Usage: $0 [add|del]"
        exit 1
        ;;
esac
