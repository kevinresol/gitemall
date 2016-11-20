# git-haxelib
Install Haxe libraries with git.

(Just a draft for now, no code has ever been written yet. As you can see.)

Until there is a Haxe library manager that does proper version locking (as in CocoaPods or Yarn), I prefer checking-in all my haxelibs in my project's git.


## Prerequisite

The current folder must be initialized with git

## Usage

`haxelib run git-haxelib [hxml]`

This command will do the following things:

0. Run `haxelib newrepo`, only if `.haxelib` not yet exists
0. Create a folder `haxelib`, if not yet exists, to hold the git submodules
0. For each dependency listed in the hxml, `git submodule add` it and its dependencies recursively.
   If the url of a library is not found (e.g. not published to haxelib.org yet), it will prompt for a input
0. Run `haxelib dev libname haxelib/libname` for each of the libraries. Then clean up the path in `.dev` files to make sure they are relative
0. Done
