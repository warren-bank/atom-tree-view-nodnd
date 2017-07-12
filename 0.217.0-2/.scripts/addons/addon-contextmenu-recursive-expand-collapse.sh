#!/usr/bin/env bash

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_SUBDIR=$( basename -s.sh "${BASH_SOURCE[0]}" )

source "${_DIR}/../0_config.sh"

# --------------------------------------------------------------------

installed_ver=`apm list -pb | grep "${new_pkg_name}@" | sed "s/${new_pkg_name}@//g"`

if [ -z "$installed_ver" ]; then
  echo "'${new_pkg_name}' package is not installed"
  exit 1
fi

if [ ! -z "$ver" ]; then
  if [ ! "$ver" == "$installed_ver" ]; then
    echo "warning: target version of 'tree-view' in configuration file (${ver}) does not match the installed version of '${new_pkg_name}' (${installed_ver})"
    echo "please update version number in configuration file to either: match the installed package, or unset its value"
    exit 1
  fi
fi

# --------------------------------------------------------------------

pkg_dir=~/.atom/packages

if [ ! -d "${pkg_dir}/${new_pkg_name}" ]; then
  echo "'${new_pkg_name}' package is not installed"
  exit 1
fi

cd "${pkg_dir}/${new_pkg_name}"

# --------------------------------------------------------------------

code_file="${_DIR}/${_SUBDIR}/tree-view.coffee.patch"

sed -i.bak "/@disposables.add atom.styles.onDidUpdateStyleElement(onStylesheetsChanged)/r ${code_file}" lib/tree-view.coffee
diff lib/tree-view.coffee lib/tree-view.coffee.bak
rm lib/tree-view.coffee.bak

# --------------------------------------------------------------------
