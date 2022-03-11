#!/bin/sh -e

# Print out dependencies for and relative to the makefile in fpga/sw
if [ "x$1" = "xDEPENDENCIES" ]; then
    echo "apps/delynx/delynx"
    exit 0
fi

echo Given buildroot path: ${1}

# Alias commands
cat >"${1}/root/.profile" <<EOF
alias ls='ls'
alias ll='ls -l'
alias la='ls -lA'
EOF

# SSH
mkdir -p "${1}/root/.ssh/"
[ -f ~/.ssh/authorized_keys ] && cp ~/.ssh/authorized_keys "${1}/root/.ssh/"

# delynx
cp -a ../apps/delynx/delynx "${1}/root/"

exit 0
