# The Jolie Release Tools

This tool automatically prepares a Jolie installation package, as used in the website.

Usage instructions:
- Clone the [Jolie repository](https://github.com/jolie/jolie).
- Clone this repository (`release_tools`).
- Go to the Jolie repo and compile, e.g., by running `ant`.
- In the directory where you cloned the `release_tools` repository, run `jolie release.ol $dir`, where `$dir` is the directory where you cloned the Jolie repository. Example: `jolie release.ol ../jolie`.
- You should now have an all-in-one installer for Jolie, `jolie-installer.jar`.
