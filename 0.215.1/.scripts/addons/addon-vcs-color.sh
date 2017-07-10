#!/usr/bin/env bash

source '../0_config.sh'

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

sed -i.bak -r "s/@element\.classList\.add\(\"status-#\{@directory\.status\}\"\) if @directory\.status\?$/\0 \&\& atom.config.get('${new_pkg_name}.enableVcsStatusCssClasses')/g" lib/directory-view.coffee
diff lib/directory-view.coffee lib/directory-view.coffee.bak
rm lib/directory-view.coffee.bak

# --------------------------------------------------------------------

sed -i.bak -r "s/@element\.classList\.add\(\"status-#\{@file\.status\}\"\) if @file\.status\?$/\0 \&\& atom.config.get('${new_pkg_name}.enableVcsStatusCssClasses')/g" lib/file-view.coffee
diff lib/file-view.coffee lib/file-view.coffee.bak
rm lib/file-view.coffee.bak

# --------------------------------------------------------------------

mv lib/tree-view.coffee lib/tree-view.coffee.bak
cat lib/tree-view.coffee.bak \
  | tr '\n' '\f'             \
  | sed -r -e "s/(\f\s+@disposables\.add atom\.config\.onDidChange )('${new_pkg_name}\.sortFoldersBeforeFiles')(, =>\f\s+@updateRoots\(\))/\1\2\3\1'${new_pkg_name}.enableVcsStatusCssClasses'\3/g" \
  | tr '\f' '\n'             \
  > lib/tree-view.coffee
diff lib/tree-view.coffee lib/tree-view.coffee.bak
rm lib/tree-view.coffee.bak

# --------------------------------------------------------------------

mv package.json package.bak.json
node -e 'try {
  let pkg = require("./package.bak.json");
  pkg.configSchema.enableVcsStatusCssClasses = {type: "boolean", default: true, description: "Allow the status of files in the VCS to be visually indicated by special CSS."};
  console.log(JSON.stringify(pkg));
  process.exit(0)
} catch(error){
  process.exit(1)
}' > package.json
if [ $? -eq 0 ]; then
  npm version "0.0.1"
  npm version "${installed_ver}"

  rm package.bak.json
  echo 'success: patch applied'
else
  rm package.json
  mv package.bak.json package.json
  echo 'error: unable to update file "package.json"'
fi

# --------------------------------------------------------------------
