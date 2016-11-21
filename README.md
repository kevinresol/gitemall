# Git'em All!
Install Haxe libraries with git.

Until there is a Haxe library manager that does proper version locking (as in CocoaPods or Yarn),
I prefer checking-in all my haxelibs in my project's git.

## Prerequisite

The current folder must be initialized with git

## Install

`haxelib --global install gitemall`

## Usage

`haxelib --global run gitemall [hxml]`

This command will do the following things:

0. Create folder `.haxelib` & `haxelib`, if not yet exist
0. Parse the hxml in current directory
0. For each dependencies, `git submodule add` it.
0. Install the libraries by specifying the path in `haxelib/libname/.dev`
0. Find haxelib.json in the libraries and parse it. Goto Step 3.
0. Done

If the url of a library is not found (e.g. not yet published to lib.haxe.org), it will prompt for user input.