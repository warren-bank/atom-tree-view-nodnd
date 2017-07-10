### addon: [addon-vcs-color](https://github.com/warren-bank/atom-tree-view-nodnd/tree/addon-vcs-color)

#### Background

* "addons" are additional patches that are unrelated to "drag and drop"
* "addons" are organized in this repo: one per orphan branch

#### Summary

* this addon (_"addon-vcs-color"_) adds an additional option to "Settings" for the package:
  * `enableVcsStatusCssClasses` is a boolean option used to determine whether or not to:<br>
    "Allow the status of files in the VCS to be visually indicated by special CSS."
* personally,
  * even when I'm working on something outside of a git repo,<br>
    I like to `git init` the "project" directory,<br>
    and add a `.gitignore` file to its root.
  * this allows me a quick and easy way to specify a filter,<br>
    which tells Atom which files and directories to include or exclude.
  * whether or not the excluded elements appear in the "tree-view" is one thing,<br>
    but far more important (to me) is whether or not these paths are ignored<br>
    when using "find in project" (which is all the time).
  * when I'm using an empty git repo to use `.gitignore` in this way,<br>
    the "tree-view" is smart enough to know that none of the files in the project directory<br>
    have been added and committed into the local git repo,
    and displays them all in a green color.
    * in this situation, it's nice to be able to disable the color<br>
      (by preventing the conditional addition of css classes, such as `status-added`)
  * when using git in a real way
    * in this situation, it's nice to see the colors that indicate unsaved changes
    * it's also nice to have the option to turn it off

#### Requirements

* assumes that a version of "tree-view" is already installed as a "community package"
