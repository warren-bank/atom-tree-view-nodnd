#!/usr/bin/env bash

source './0_config.sh'

if [ -z "$ver" ]; then
  echo 'please configure the version of "tree-view" to patch'
  exit 1
fi

cd ..

# --------------------------------------------------------------------

new_dirname="${new_pkg_name}-${ver}"

if [ ! -e "${new_dirname}.7z" ]; then
  echo 'please apply patch before attempting to install'
  exit 1
fi

# --------------------------------------------------------------------

pkg_dir=~/.atom/packages

if [ ! -d "$pkg_dir" ]; then
  mkdir -p "$pkg_dir"
fi

cp "${new_dirname}.7z" "$pkg_dir/"
cd "$pkg_dir"
7z x "${new_dirname}.7z"
rm "${new_dirname}.7z"
mv "${new_dirname}" "${new_pkg_name}"
cd "${new_pkg_name}"

# --------------------------------------------------------------------

apm install

# --------------------------------------------------------------------
