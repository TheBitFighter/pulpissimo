# Partition, format and mount target partitions
cat >"sf_disk" <<EOF
label: dos
device: /dev/sdb
unit: sectors

type=b, start=2048, size=${BOOT_BLOCKS}, bootable
type=83
EOF
