# Sanity check for block device
export sd_dev="${1:-/dev/mmcblk0}"
if [ ! -b "$sd_dev" ]; then
    echo "Path \"$sd_dev\" does not point to a block device.">&2
    echo "Please supply a valid device as first argument to this script.">&2
    exit 1
fi
