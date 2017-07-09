#!/usr/bin/env bash

ver=`apm list -pb | grep 'tree-view@' | sed 's/tree-view@//g'`

new_pkg_name=tree-view-nodnd
