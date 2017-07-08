#!/usr/bin/env bash

old_pkg_name=tree-view

source './0_config.sh'

if [ -z "$ver" ]; then
  echo "please configure the version of '${old_pkg_name}' to patch"
  exit 1
fi

cd ..

# --------------------------------------------------------------------

# disable drag-and-drop in Atom ("tree-view" package)

# https://github.com/atom/tree-view/issues/588
# https://github.com/atom/tree-view/pull/623
# https://github.com/atom/tree-view/pull/623/commits/6614d3417b5ac31e8fc00550092fa0947c2df068

# https://github.com/atom/tree-view/releases

# --------------------------------------------------------------------

old_dirname="${old_pkg_name}-${ver}"
new_dirname="${new_pkg_name}-${ver}"

if [ ! -e "${old_dirname}.zip" ]; then
  wget -O "${old_dirname}.zip" "https://github.com/atom/tree-view/archive/v${ver}.zip"
fi
7z x "${old_dirname}.zip"
mv "${old_dirname}" "${new_dirname}"
cd "${new_dirname}"

# --------------------------------------------------------------------

rm -rf spec

# --------------------------------------------------------------------

sed -i.bak "s/@element.draggable = true/@element.draggable = atom.config.get('${old_pkg_name}.enableDragAndDrop')/g" lib/directory-view.coffee
diff lib/directory-view.coffee lib/directory-view.coffee.bak
rm lib/directory-view.coffee.bak

# --------------------------------------------------------------------

sed -i.bak "s/@element.draggable = true/@element.draggable = atom.config.get('${old_pkg_name}.enableDragAndDrop')/g" lib/file-view.coffee
diff lib/file-view.coffee lib/file-view.coffee.bak
rm lib/file-view.coffee.bak

# --------------------------------------------------------------------

mv lib/tree-view.coffee lib/tree-view.coffee.bak
cat lib/tree-view.coffee.bak | tr '\n' '\f' | sed -r -e "s/(\f\s+@disposables\.add atom\.config\.onDidChange )('${old_pkg_name}\.sortFoldersBeforeFiles')(, =>\f\s+@updateRoots\(\))/\1\2\3\1'${old_pkg_name}.enableDragAndDrop'\3/g" | tr '\f' '\n' > lib/tree-view.coffee
diff lib/tree-view.coffee lib/tree-view.coffee.bak
rm lib/tree-view.coffee.bak

# --------------------------------------------------------------------

# note: this will reformat the whitespace (pretty-print) in "package.json".
#       "util.format('%j', json)" is the closest we can get, without installing modules, but the string it produces cannot be parsed as JSON outside of javascript (Object attribute names aren't in quotes).
#       "JSON.stringify" produces a string with no whitespace, but it is valid JSON.
# note  due to whitespace issues and also that Objects in javascript are unordered, "diff" generates too much noise and not enough signal.
# note: backup file uses extension ".bak.json" so it is still recognized by Node as a json data file.
mv package.json package.bak.json
node -e 'try {
  let pkg = require("./package.bak.json");
  if (pkg.configSchema.enableDragAndDrop !== undefined) throw false
  pkg.configSchema.enableDragAndDrop = {type: "boolean", default: false, description: "Enable dragging and dropping of files and directories within the tree view."};
  pkg.name = process.argv[1]
  delete pkg.repository
  console.log(JSON.stringify(pkg));
  process.exit(0)
} catch(error){
  process.exit(1)
}' "${new_pkg_name}" > package.json
if [ $? -eq 0 ]; then
  # diff -w package.json package.bak.json
  rm package.bak.json
else
  rm package.json
  mv package.bak.json package.json
  echo 'error: unable to update file "package.json"'
fi

# --------------------------------------------------------------------

grep -Frl "'${old_pkg_name}." . | xargs sed -i "s/'${old_pkg_name}\./'${new_pkg_name}\./g"
grep -Frl "'${old_pkg_name}:" . | xargs sed -i "s/'${old_pkg_name}:/'${new_pkg_name}:/g"

# --------------------------------------------------------------------

cd ..
if [ -e "${new_dirname}.7z" ]; then
  rm "${new_dirname}.7z"
fi
7z a -t7z "${new_dirname}.7z" -r "${new_dirname}/"
if [ $? -eq 0 ]; then
  rm -rf "${new_dirname}"
fi

# --------------------------------------------------------------------
