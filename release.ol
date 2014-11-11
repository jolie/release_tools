include "exec.iol"
include "file.iol"

constants {
	ReleaseDir = "release"
}

// Example usage: jolie release.ol ../branches/jolie_1_0

define exec
{
	exec@Exec( e )()
}

define compile
{
	e = "ant";
	e.workingDirectory = args[0];
	e.waitFor = 1;
	e.stdOutConsoleEnable = true;
	exec;
	undef( e )
}

define recreateReleaseDir
{
	e = "rm";
	e_arg = "-rf";
	e_arg = ReleaseDir;
	e.waitFor = 1;
	e.stdOutConsoleEnable = true;
	exec@Exec( e )();
	
	undef( e.args );
	e = "mkdir";
	e_arg = ReleaseDir;
	exec;

	
	undef( e )
}

define reset_args
{
	undef( e.args )
}

main
{
	e_arg -> e.args[#e.args];
//	compile;

	recreateReleaseDir;	

	e = "cp";
	e_arg = "-Rp";
	e_arg = args[0] + "/dist";
	e_arg = ReleaseDir + "/dist";
	e.waitFor = 1;
	exec;

	reset_args;
	e_arg = "jolie_installer/dist/jolie_installer.jar";
	e_arg = ReleaseDir + "/jolie_installer.jar";
	exec;

	reset_args;
	e = "zip";
	e.workingDirectory = "release";
	e_arg = "-r";
	e_arg = "dist.zip";
	e_arg = "dist";
	exec;
	undef( e.workingDirectory );
	
	reset_args;
	e = "jar";
	e_arg = "uvfm";
	e_arg = ReleaseDir + "/jolie_installer.jar";
	e_arg = "scripts/MANIFEST.MF";
	e_arg = "-C";
	e_arg = ReleaseDir;
	e_arg = "dist.zip";
	e_arg = "-C";
	e_arg = ReleaseDir + "/dist/jolie";
	e_arg = "jolie.jar";
	e_arg = "-C";
	e_arg = ReleaseDir + "/dist/jolie";
	e_arg = "lib/libjolie.jar";
	e_arg = "scripts/installer.ol";
	exec
}

