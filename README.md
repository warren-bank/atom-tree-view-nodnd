### [tree-view-nodnd](https://github.com/warren-bank/atom-tree-view-nodnd)

#### Background

The Atom text editor includes the core package: [tree-view](https://github.com/atom/tree-view).

This tree view includes a drag-and-drop feature to enable moving files and directories.

Personally, I would never intentionally use this feature. However, there are many times that I feel as though I may have accidentally moved files. There's no log to check to confirm that such an operation has happened. And there's no easy way to undo such an operation. It's a dangerous feature to have enabled. However, Atom doesn't include any configurable option to disable this feature. There have been several issues (ex: [566](https://github.com/atom/tree-view/issues/566), [588](https://github.com/atom/tree-view/issues/588), [996](https://github.com/atom/tree-view/issues/996), ...) and feature requests from users asking for this configuration option. However, the core team rejects pull requests and is adamant that it's a good feature and everyone should shutup and like it.

Some of my favorite contributions include:
* [pull request 623](https://github.com/atom/tree-view/pull/623) by user: [Tyriar](https://github.com/Tyriar)
  * adds the boolean option: "Enable Drag and Drop"
* [commit](https://github.com/Liberton/tree-view/commit/e61b66ab68dca69009b4ed1875f2d50f08024b38) by user: [marceloadsj](https://github.com/marceloadsj)
  * adds a confirmation dialog to drop events, which prompts the user to confirm the move operation before it is allowed to occur

However, there isn't any fork that includes both options. Even if there was, I don't want to be stuck using a particular version of the package from several years ago. And I'm against downloading pre-built packages from users who I don't know, and don't trust.

Instead, I combined both of these ideas and wrote shell scripts that will apply the necessary changes as a patch against any fairly current release.

* script 1 (`1_apply_patch.sh`):
  * downloads a specific (ie: target) version of "tree-view" from github
  * unzips it
  * applies a few in-place text edits
  * zips up a modified 7-zip archive
* script 2 (`2_install.sh`):
  * copies the modified 7-zip archive to Atom's packages directory
  * unzips it
  * installs it

The code is easy to audit, so it can be used safely. The only "coding" a user needs to perform is to update a configuration file to specify the target version of "tree-view".

#### Installation Instructions

* start Atom:
  * Edit > Preferences > Packages
  * under "Core Packages",<br>
    scroll nearly to the bottom and find the package named: "tree-view"
  * click: "Disable"
  * tip:
    * make a note of which version this is
* exit Atom
* edit the file: `./.scripts/0_config.sh`
  * configure the name for the new package
    * default: "tree-view-nodnd"
  * configure the version of "tree-view" to download and patch
    * tip:
      * use the same version that came bundled with Atom,<br>
        which was just disabled
      * when I tried the most recent release,<br>
        Atom refused to install the package,<br>
        and listed problems with links to github issues
      * patching the same package seems like an easy way to avoid version mismatch
* run:

```bash
cd ./.scripts
./1_apply_patch.sh
./2_install.sh
```

* start Atom:
  * Edit > Preferences > Packages
  * under "Community Packages",<br>
    you'll see the newly installed package<br>
    (displayed using the name as it was configured)
  * it should already be enabled
  * in its "Settings",
    * "Enable Drag and Drop" is disabled by default
    * "Confirm Drag and Drop" is enabled by default

#### Uninstall Instructions (GUI)

* start Atom:
  * Edit > Preferences > Packages
    * "Community Packages" > "tree-view-nodnd"
      * click: "Uninstall"
    * "Core Packages" > "tree-view"
      * click: "Enable"

#### Uninstall Instructions (command-line)

* run:

```bash
apm remove "tree-view-nodnd"
apm enable "tree-view"
```

#### Final Comments

* though the scripts should work on all recent versions of "tree-view" without requiring any changes,
  * this repo includes them under specific version(s)
  * if a new version of "tree-view" was to make a change that requires a slight modification to `1_apply_patch.sh`,
    * I'll add that new version to the rep
    * under that new version, the directory will contain the updated scripts
  * presumably, you have a target version of "tree-view" in mind
    * look for the version directory in this repo that is `lte` (less than or equal to) your target
    * copy, configure, and run the scripts contained there-in
* each version directory in the repo contains additional files that can safely be ignored/deleted:
  * the unmodified `.zip` archive (downloaded from github by `1_apply_patch.sh`)
  * the modified `.7z` archive (produced as output by `1_apply_patch.sh`)
