### [tree-view-nodnd](https://github.com/warren-bank/atom-tree-view-nodnd)

#### Background

The Atom text editor includes the core package: [tree-view](https://github.com/atom/tree-view).

This tree view includes a drag-and-drop feature to enable moving files and directories.

Personally, I would never intentionally use this feature. However, there are many times that I feel as though I may have accidentally moved files. There's no log to check to confirm that such an operation has happened. And there's no easy way to undo such an operation. It's a dangerous feature to have enabled. However, Atom doesn't include any configurable option to disable this feature. There have been several issues and feature requests from users asking for this configuration option. However, the core team rejects pull requests and is adamant that it's a good feature and everyone should shutup and like it.

One such pull request is [#623](https://github.com/atom/tree-view/pull/623) by the github user: [Tyriar](https://github.com/Tyriar)

I like it. However, I don't want to be stuck using a particular version of the package from several years ago. I'm also against downloading pre-built packages from users who I don't know, and don't trust.

Instead, I took his idea and wrote a shell script to apply his changes as a patch against any fairly current release. Its configuration needs to know the target version. Then, it downloads the version from github and applies a few in-place text edits before installing the package into Atom. The code is easy to audit, so it can be used safely.

#### Installation Instructions

* start Atom:
  * Edit > Preferences > Packages
  * under "Core Packages",<br>
    scroll nearly to the bottom and find the package named: "tree-view"
  * click: "Disable"
  * tip:
    * make a note of which version this is
* exit Atom
* configure the version of "tree-view" to download and patch:
  * edit the file: `./.scripts/0_config.sh`
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
    you'll see the newly installed package named: "tree-view-nodnd"
  * it should already be enabled
  * in its "Settings",<br>
    "Enable Drag and Drop" is disabled by default
