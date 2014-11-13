include "exec.iol"
include "console.iol"
include "file.iol"
include "string_utils.iol"
include "runtime.iol"
include "inst_interface.iol"

execution{ concurrent }

constants
{
	DEFAULT_JOLIE_HOME = "/opt/jolie",
	DEFAULT_LAUNCHERS_PATH = "/usr/bin",
	DIST_PACKAGE_PATH = "../dist.zip",
	LAUNCHERS_PATH = "launchers/unix"
}

inputPort In {
	Location: "local"
  Interfaces: InstInterface
}

main
{
	[ unzipDist()(){
		// cleans DIST_FOLDER
		e = "rm";
		e.args[#e.args] = "-rf";
		e.args[#e.args] = DIST_FOLDER;
		e.waitFor = 1;
		exec@Exec( e )();
		undef( e );

		// unzip dist.zip
		e = "unzip";
		e.args[#e.args] = DIST_PACKAGE_PATH;
		e.args[#e.args] = "-x";
		e.args[#e.args] = DIST_FOLDER;
		e.waitFor = 1;
		exec@Exec( e )()
	}]{ nullProcess }
	[ getJH( req )( res ){
		e = "sh";
		e.args[#e.args] = "-c";
		e.args[#e.args] = "echo $" + JOLIE_HOME;
		e.waitFor = 1;
		exec@Exec( e )( e_res );
		res = e_res;
		trim@StringUtils( res )( res )
	}]{ nullProcess }
	[ getDJH()( DEFAULT_JOLIE_HOME ){ nullProcess }]{ nullProcess }
	[ getDLP()( DEFAULT_LAUNCHERS_PATH ){ nullProcess }]{ nullProcess }
	[ setJH( jh )(){
		println@Console( "\nPlease, open a new shell and execute " + 
			"the command below:\n" )();
		println@Console( "echo 'export JOLIE_HOME=\"" + jh + 
			"\"' >> ~/.bash_profile" )()
	} ]{ nullProcess }
	[ copyBins( bin_folder )(){
		// removes the destination folder
		e = "sh";
		e.args[#e.args] = "-c";
		e.args[#e.args] = "rm -rf " + bin_folder;
		e.waitFor = 1;
		exec@Exec( e )( e_res );
		println@Console( e_res.stderr )();
		undef( e_res );
		undef( e );

		// creates destination folder
		e = "sh";
		e.args[#e.args] = "-c";
		e.args[#e.args] = "mkdir " + bin_folder;
		e.waitFor = 1;
		exec@Exec( e )( e_res );
		undef( e_res );
		undef( e );

		// copy the content of dist/jolie
		e = "sh";
		e.args[#e.args] = "-c";
		e.args[#e.args] = "cp -rp " + DIST_FOLDER + "/" + 
			JOLIE_FOLDER + "/* " + bin_folder;
		e.waitFor = 1;
		exec@Exec( e )( e_res )
	}]{ nullProcess }
	[ copyLaunchers( l_folder )( dir_exists ){
		// checks if the directory exists
		e = "sh";
		e.args[#e.args] = "-c";
		e.args[#e.args] = "echo ~";
		exec@Exec( e )( e_res );
		user_home = e_res;
		trim@StringUtils( user_home )( user_home );
		ts = l_folder;
		ts.replacement = user_home;
		ts.regex = "~";
		replaceAll@StringUtils( ts )( l_folder );
		isDirectory@File( l_folder )( dir_exists );
		if( dir_exists ) {
			// copy the content of launchers/unix
			undef( e );
			e = "sh";
			e.args[#e.args] = "-c";
			e.args[#e.args] = "cp	-rp " + DIST_FOLDER + "/" + LAUNCHERS_PATH + 
			"/* " + l_folder;
			e.waitFor = 1;
			exec@Exec( e )( e_res )  
		} else {
			println@Console( "\nFolder \"" + l_folder + "\" not found. Please specify" +
				" an existing folder.\n" )()
		}
		
	}]{ nullProcess }
}