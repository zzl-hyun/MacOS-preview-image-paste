#!/bin/zsh
set -euo pipefail

script_dir="${0:A:h}"
install_dir="${HOME}/bin"
mkdir -p "$install_dir"
xcrun swiftc "$script_dir/png2preview.swift" -o "$install_dir/png2preview"
print "Installed: $install_dir/png2preview"
print 'Run: ~/bin/png2preview --capture'
