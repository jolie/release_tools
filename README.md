# The Jolie Release Tools

This tool automatically prepares a Jolie installation package, as used in the website.

Usage instructions:
- Clone the [Jolie repository](https://github.com/jolie/jolie);
- Clone this repository (`release_tools`);
- Go to the `jolie` repo and compile, e.g., by running `ant`;
- Go to the `release_tools` repo
  - enter the `jolie_installer` and compile the installer e.g., by running `ant`;
  - go back in the root of `release_tools` repo and run `jolie release.ol $dir [$jar_name]`, where `$dir` is the directory where you cloned the Jolie repository and the `$jar_name` (optional) is the jar file name without extension (default value is jolie_installer). Example: `jolie release.ol ../jolie jolie_installer`;
  - under folder `release` there should be an all-in-one installer for Jolie `jolie-installer.jar` or the specified `$jar_name.jar`.