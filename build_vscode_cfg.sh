#!/bin/bash

set -euo pipefail

if [ $# -lt 2 ] || [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: missing container name." >&2
    echo "Usage: $0 <container_name> <remote_user>" >&2
    exit 1
fi

OUTPUT_FILE="$HOME/.config/Code/User/globalStorage/ms-vscode-remote.remote-containers/imageConfigs/$1.json"
REMOTE_USER="$2"

cat > "$OUTPUT_FILE" << EOF
{
	"remoteUser": "$REMOTE_USER",
	"workspaceFolder": "/work"
}
EOF

echo "Created - $OUTPUT_FILE"
echo "Remote user - $REMOTE_USER"