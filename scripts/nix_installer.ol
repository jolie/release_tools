/************************************************************************************
 *   Copyright (C) 2014 by Saverio Giallorenzo <saverio.giallorenzo@gmail.com> 			*
 *                                                                               		*
 *   This program is free software; you can redistribute it and/or modify  					*
 *   it under the terms of the GNU Library General Public License as       					*
 *   published by the Free Software Foundation; either version 2 of the    					*
 *   License, or (at your option) any later version.                         				*
 *                                                                               		*
 *   This program is distributed in the hope that it will be useful,             		*
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of              		*
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               		*
 *   GNU General Public License for more details.                                		*
 *                                                                               		*
 *   You should have received a copy of the GNU Library General Public           		*
 *   License along with this program; if not, write to the                       		*
 *   Free Software Foundation, Inc.,                                             		*
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   		*
 *                                                                               		*
 *   For details about the authors of this software, see the AUTHORS file.       		*
 ***********************************************************************************/

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
	LAUNCHERS_PATH = "launchers/unix"
}

inputPort In {
	Location: "local"
  Interfaces: InstInterface
}

init
{
		getServiceDirectory@File()( cd )
}

main
{
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
		e = "sh";
		e.args[#e.args] = "-c";
		e.args[#e.args] = "echo " + jh;
		exec@Exec( e )( e_res );
		f = e_res;
		trim@StringUtils( f )( f );
		println@Console( "\nPlease, open a new shell and execute " + 
			"the command below:\n" )();
		println@Console( "echo 'export JOLIE_HOME=\"" + f + 
			"\"' >> ~/.bash_profile" )()
	} ]{ nullProcess }
	[ copyBins( bin_folder )(){
		// removes the destination folder
		e = "sh";
		e.args[#e.args] = "-c";
		e.args[#e.args] = "rm -rf " + bin_folder;
		e.waitFor = 1;
		exec@Exec( e )( e_res );
		undef( e );

		// creates destination folder
		e = "sh";
		e.args[#e.args] = "-c";
		e.args[#e.args] = "mkdir " + bin_folder;
		e.waitFor = 1;
		exec@Exec( e )( e_res );
		undef( e );

		// copy the content of dist/jolie
		e = "sh";
		e.args[#e.args] = "-c";
		e.args[#e.args] = "cp -rp " + cd + "/" + DIST_FOLDER + "/" + 
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
			e.args[#e.args] = "cp	-rp " + cd + "/" + DIST_FOLDER + "/" + LAUNCHERS_PATH + 
			"/* " + l_folder;
			e.waitFor = 1;
			exec@Exec( e )( e_res )  
		} else {
			println@Console( "\nFolder \"" + l_folder + "\" not found. Please specify" +
				" an existing folder.\n" )()
		}
		
	}]{ nullProcess }
}