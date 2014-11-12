include "exec.iol"
include "console.iol"
include "file.iol"
include "string_utils.iol"
include "inst_interface.iol"

execution{ concurrent }

constants
{
	DEFAULT_JOLIE_HOME = "/opt/jolie",
	DEFAULT_LAUNCHERS_PATH = "/usr/bin"
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
		e = "bash";
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
		println@Console( "Please, open a new shell and copy-paste " + 
			"the command below:\n" )();
		println@Console( "echo 'export JOLIE_HOME=\"" + jh + 
			"\"' >> ~/.bash_profile" )()
	} ]{ nullProcess }
	[ copyBins( bin_folder )(){
		// removes possible previous folder
		e = "rm";
		e.args[#e.args] = "-rf";
		e.args[#e.args] = bin_folder;
		e.waitFor = 1;
		exec@Exec( e )( e_res );
		println@Console( e_res.stderr )();
		undef( e_res );
		undef( e );

		// makes new folder
		e = "mkdir";
		e.args[#e.args] = bin_folder;
		e.waitFor = 1;
		exec@Exec( e )( e_res );
		println@Console( e_res.stderr )();
		undef( e_res );
		undef( e );

		// copy the content of dist/jolie
		e = "cp";
		e.args[#e.args] = "-rp";
		e.args[#e.args] = DIST_FOLDER + "/" + JOLIE_FOLDER;
		e.args[#e.args] = bin_folder;
		e.waitFor = 1;
		exec@Exec( e )( e_res );
		println@Console( e_res.stderr )()
	}]{ nullProcess }
}