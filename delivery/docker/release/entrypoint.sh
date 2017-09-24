#!/bin/sh

# Include golang binaries in PATH
export PATH=/opt/demo:$PATH

# Run entrypoint.sh arguments
exec $@
