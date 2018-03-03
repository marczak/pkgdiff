# pkgdiff
Very basic script that compares a an Apple pkg with what's on disk

## Wait...what?
This is a really basic, really poor bash script for macOS that will compare a .pkg file with what's already on your disk. It's a quick and easy (cheesy?) way to tell chat a package is installing or changing.

## Why is this crap?
Basically, this script blindly trusts the package's BOM file, which could be wrong, and ignores any scripts that may perform further installation. (Some packages install *all* of their files by uncompressing a blob via a postinstall script.) There's also little to no error checking.

## Things to do
To improve this script, there are several things that could be done:

* Take command-line arguments for debug-level, general verbosity, and granular reporting.
* Do more work for the user, such as mounting a DMG file, and then attacking the package inside.
* Analyze postinstall scripts

## YOLO
This script has been a nice tool for me for a few years, and I figured I'd finally share it. If you like it, great. I know it's far from perfect. If you do, too, pull requests are welcome.
