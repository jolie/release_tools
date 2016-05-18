# The Jolie Release Tools

This tool automatically prepares a Jolie installation package, as used in the website.

Usage instructions:
- Clone the [Jolie repository](https://github.com/jolie/jolie);
- Clone this repository (`release_tools`);
- Go to the `Jolie` repo and compile, e.g., by running `ant`;
- Go to the `release_tools` repo
  - enter the `jolie_installer` and compile the installer e.g., by running `ant`;
  - go back in the root of `release_tools` repo and run `jolie release.ol $dir`, where `$dir` is the directory where you cloned the Jolie repository. Example: `jolie release.ol ../jolie`;
  - under folder `release` there should be an all-in-one installer for Jolie `jolie-installer.jar`.
