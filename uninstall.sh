#!/bin/zsh
set -euo pipefail

target="${HOME}/bin/png2preview"
if [[ -e "$target" ]]; then
    rm "$target"
    print "Removed: $target"
else
    print "Nothing to remove: $target"
fi
