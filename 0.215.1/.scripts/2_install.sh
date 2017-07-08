#!/usr/bin/env bash

source './0_config.sh'

if [ -z "$ver" ]; then
  echo 'please configure the version of "tree-view" to patch'
  exit 1
fi

cd ..

# --------------------------------------------------------------------

original="tree-view-$ver"
final="tree-view-nodnd"

if [ ! -e "$original-nodnd.7z" ]; then
  echo 'please apply patch before attempting to install'
  exit 1
fi

# --------------------------------------------------------------------

pkg_dir=~/.atom/packages

if [ ! -d "$pkg_dir" ]; then
  mkdir -p "$pkg_dir"
fi

cp "$original-nodnd.7z" "$pkg_dir/"
cd "$pkg_dir"
7z x "$original-nodnd.7z"
rm "$original-nodnd.7z"
mv "$original-nodnd" "$final"
cd "$final"

# --------------------------------------------------------------------

apm install

# --------------------------------------------------------------------
