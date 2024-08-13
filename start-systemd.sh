#!/usr/bin/env bash
# Running systemd in container if it is not started at be beginning.
#
# Use case: Github action maybe run in a container, but users cannot 
#           customize entrypoint. If users want to run action in systemd
#           context, this script will help.
#
# NOTE: --privileged is required when creating the container.
#       GDB is required.
#       root is required.
#

set -eu

if [ "$EUID" -ne 0 ];then 
  echo "Error: please run as root"
  false
fi

if ! gdb --version >/dev/null 2>&1; then
  echo "Error: No GDB installed!"
  false
fi

if [ "$(ps --pid 1 -o command=)" != '/usr/sbin/init' ]; then
    cat <<EOF >/tmp/systemd.gdb
handle all nostop pass
break main
call (int)execl("/usr/sbin/init", "/usr/sbin/init", 0)
detach
quit
EOF

    gdb --pid 1 -q --batch-silent -x /tmp/systemd.gdb >/tmp/start-systemd.log 2>&1 || :
    test "$(ps --pid 1 -o command=)" = '/usr/sbin/init'
fi
