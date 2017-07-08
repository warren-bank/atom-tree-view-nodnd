#!/usr/bin/env bash

source './0_config.sh'

if [ -z "$ver" ]; then
  echo 'please configure the version of "tree-view" to patch'
  exit 1
fi

cd ..

# --------------------------------------------------------------------

# disable drag-and-drop in Atom ("tree-view" package)

# https://github.com/atom/tree-view/issues/588
# https://github.com/atom/tree-view/pull/623
# https://github.com/atom/tree-view/pull/623/commits/6614d3417b5ac31e8fc00550092fa0947c2df068

# https://github.com/atom/tree-view/releases
# https://github.com/atom/tree-view/archive/v0.217.3.zip
#   most recent release version

# --------------------------------------------------------------------

original="tree-view-$ver"
if [ ! -e "$original.zip" ]; then
  wget -O "$original.zip" "https://github.com/atom/tree-view/archive/v$ver.zip"
fi
7z x "$original.zip"
mv "$original" "$original-nodnd"
cd "$original-nodnd"

# --------------------------------------------------------------------

sed -i.bak "s/@element.draggable = true/@element.draggable = atom.config.get('tree-view.enableDragAndDrop')/g" lib/directory-view.coffee
diff lib/directory-view.coffee lib/directory-view.coffee.bak
rm lib/directory-view.coffee.bak

# --------------------------------------------------------------------

sed -i.bak "s/@element.draggable = true/@element.draggable = atom.config.get('tree-view.enableDragAndDrop')/g" lib/file-view.coffee
diff lib/file-view.coffee lib/file-view.coffee.bak
rm lib/file-view.coffee.bak

# --------------------------------------------------------------------

mv lib/tree-view.coffee lib/tree-view.coffee.bak
cat lib/tree-view.coffee.bak | tr '\n' '\f' | sed -r -e "s/(\f\s+@disposables\.add atom\.config\.onDidChange )('tree-view\.sortFoldersBeforeFiles')(, =>\f\s+@updateRoots\(\))/\1\2\3\1'tree-view.enableDragAndDrop'\3/g" | tr '\f' '\n' > lib/tree-view.coffee
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
  pkg.name += "-nodnd"
  delete pkg.repository
  console.log(JSON.stringify(pkg));
  process.exit(0)
} catch(error){
  process.exit(1)
}' > package.json
if [ $? -eq 0 ]; then
  # diff -w package.json package.bak.json
  rm package.bak.json
else
  rm package.json
  mv package.bak.json package.json
  echo 'error: unable to update file "package.json"'
fi

# --------------------------------------------------------------------

cd ..
if [ -e "$original-nodnd.7z" ]; then
  rm "$original-nodnd.7z"
fi
7z a -t7z "$original-nodnd.7z" -r "$original-nodnd/"
if [ $? -eq 0 ]; then
  rm -rf "$original-nodnd"
fi

# --------------------------------------------------------------------
