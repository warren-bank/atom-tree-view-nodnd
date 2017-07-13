### addon: [addon-open-in-terminal](https://github.com/warren-bank/atom-tree-view-nodnd/tree/addon-open-in-terminal)

#### Background

* "addons" are additional patches that are unrelated to "drag and drop"
* "addons" are organized in this repo: one per orphan branch

#### Summary

* this addon (_"addon-open-in-terminal"_) adds an additional option to the context-menu in the "tree-view":<br>
  "Open in Terminal"
* selecting this menu item causes a (system dependent) terminal emulator program to run,<br>
  and the working directory is set based on the element in "tree-view" that was clicked
    * if the element is not a directory, then its parent directory is used

#### Requirements

* assumes that a version of "tree-view" is already installed as a "community package"
