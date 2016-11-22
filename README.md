# Git'em All!
Install Haxe libraries with git.

Until there is a Haxe library manager that does proper version locking (as in CocoaPods or Yarn),
I prefer checking-in all my haxelibs in my project's git as submodules.

## Install

`haxelib --global install gitemall`

## Usage

`haxelib --global run gitemall [hxml]`

## Quick Start

0. Create a directory: `mkdir my_new_proj`
0. Initialize Git: `cd my_new_proj && git init`
0. Write a hxml file: `echo "-main Main -js bin/index.js -lib tink_web -lib buddy" > build.hxml`
0. Git'em All!!! `haxelib --global run gitemall` (Be prepared to input urls manually when they can't be found)

## Explained

This little program will do the following things:

0. Create folder `.haxelib` & `haxelib`, if not yet exist
0. Parse the hxml in current directory
0. For each dependencies, `git submodule add` it.
0. Install the libraries by specifying the path in `haxelib/libname/.dev`
0. Find haxelib.json in the libraries and parse it. Goto Step 3.
0. Run `git submodule update --init --recursive`, to fetch all submodules reference by the libraries
0. Done

If the url of a library is not found (e.g. not yet published to lib.haxe.org), it will prompt for user input.
