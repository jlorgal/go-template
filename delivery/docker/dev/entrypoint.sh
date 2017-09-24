#!/bin/sh

# Include golang binaries in PATH
export PATH=/root/go/bin:$PATH

# Run entrypoint.sh arguments
exec $@
