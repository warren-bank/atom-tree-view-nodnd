#!/usr/bin/env bash

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_SUBDIR=$( basename -s.sh "${BASH_SOURCE[0]}" )

old_pkg_name=tree-view

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

mv lib/tree-view.coffee lib/tree-view.coffee.bak
cat lib/tree-view.coffee.bak \
  | tr '\n' '\f'             \
  | sed -r -e "s/(\f)(\s+)('${new_pkg_name}:show-in-file-manager': => @showSelectedEntryInFileManager\(\))/\1\2\3\1\2'${new_pkg_name}:show-in-terminal': => @showSelectedEntryInTerminal()/g" \
  | sed -r -e "s/(\f\s+@disposables\.add atom\.config\.onDidChange )('${new_pkg_name}\.sortFoldersBeforeFiles')(, =>\f\s+@updateRoots\(\))/\1\2\3\1'${new_pkg_name}.terminalExecutable'\3/g" \
  | tr '\f' '\n'             \
  > lib/tree-view.coffee
diff lib/tree-view.coffee lib/tree-view.coffee.bak
rm lib/tree-view.coffee.bak

# --------------------------------------------------------------------

mv package.json package.bak.json
node -e 'try {
  let pkg = require("./package.bak.json");
  pkg.configSchema.terminalExecutable = {"type":"string","default":"gnome-terminal","enum":["lxterminal","xfce4-terminal","gnome-terminal","konsole","guake","xterm"],"description":"terminal emulator binary (only used in Linux environment)"};
  console.log(JSON.stringify(pkg));
  process.exit(0)
} catch(error){
  process.exit(1)
}' > package.json
if [ $? -eq 0 ]; then
  # hacky, but allow npm to reformat "package.json"
  npm version "0.0.1"
  npm version "${installed_ver}"

  diff package.json package.bak.json
  rm package.bak.json
else
  rm package.json
  mv package.bak.json package.json
  echo 'error: unable to update file "package.json"'
fi

# --------------------------------------------------------------------

sed "s/'${old_pkg_name}\./'${new_pkg_name}\./g" "${_DIR}/${_SUBDIR}/tree-view.coffee.patch" > "${_DIR}/${_SUBDIR}/tree-view.coffee.patch.tmp"
sed "s/'${old_pkg_name}:/'${new_pkg_name}:/g"   "${_DIR}/${_SUBDIR}/tree-view.cson.patch"   > "${_DIR}/${_SUBDIR}/tree-view.cson.patch.tmp"

# --------------------------------------------------------------------

code_file="${_DIR}/${_SUBDIR}/tree-view.coffee.patch.tmp"

sed -i.bak "/@openInFileManager(command, args, label, true)/r ${code_file}" lib/tree-view.coffee
diff lib/tree-view.coffee lib/tree-view.coffee.bak
rm lib/tree-view.coffee.bak
rm "${code_file}"

# --------------------------------------------------------------------

code_file="${_DIR}/${_SUBDIR}/tree-view.cson.patch.tmp"

sed -i.bak "/'context-menu':/r ${code_file}" menus/tree-view.cson
diff menus/tree-view.cson menus/tree-view.cson.bak
rm menus/tree-view.cson.bak
rm "${code_file}"

# --------------------------------------------------------------------
