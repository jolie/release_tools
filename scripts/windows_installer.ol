/***********************************************************************************
 *   Copyright (C) 2014 by Saverio Giallorenzo <saverio.giallorenzo@gmail.com>     *
 *   Copyright (C) 2014 by Fabrizio Montesi <famontesi@gmail.com>                  *
 *                                                                                 *
 *   This program is free software; you can redistribute it and/or modify          *
 *   it under the terms of the GNU Library General Public License as               *
 *   published by the Free Software Foundation; either version 2 of the            *
 *   License, or (at your option) any later version.                               *
 *                                                                                 *
 *   This program is distributed in the hope that it will be useful,               *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of                *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                 *
 *   GNU General Public License for more details.                                  *
 *                                                                                 *
 *   You should have received a copy of the GNU Library General Public             *
 *   License along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                               *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                     *
 *                                                                                 *
 *   For details about the authors of this software, see the AUTHORS file.         *
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
	DEFAULT_JOLIE_HOME = "C:\\Program Files\\Jolie",
	DEFAULT_LAUNCHERS_PATH = "C:\\Program Files\\Jolie",
	LAUNCHERS_PATH = "launchers/windows"
}

inputPort In {
Location: "local"
Interfaces: InstInterface
}

outputPort Self {
Interfaces: InstInterface
}

init
{
	getServiceDirectory@File()( cd );
	getLocalLocation@Runtime()( Self.location )
}

main
{
	[ normalisePath( path )( path ) {
		nullProcess
	} ] { nullProcess }

	[ getDJH()( DEFAULT_JOLIE_HOME ) { nullProcess } ] { nullProcess }

	[ getDLP()( DEFAULT_LAUNCHERS_PATH ){ nullProcess } ]{ nullProcess }

	[ installationFinished( jh )() {
		e = "setx";
		e.args[#e.args] = "JOLIE_HOME";
		e.args[#e.args] = jh;
		e.args[#e.args] = "/m";
		e.waitFor = 1		
	} ] { nullProcess }
	
	[ deleteDir( dir )() {
		deleteDir@File( bin_folder )( delete_resp );
		if ( !delete_resp ) { throw( CannotDeleteBinFolder ) }
	} ] { nullProcess }
	
	[ mkdir( dir )() {
		mkdir@File( bin_folder )( delete_resp );
		if ( !delete_resp ) { throw( CannotCreateBinFolder ) }		
	} ] { nullProcess }

	[ copyBins( bin_folder )(){
		// copy the content of dist/jolie
		copy.from = cd + "/" + DIST_FOLDER + "/" + JOLIE_FOLDER + "/";
		copy.to = bin_folder;
		copyDir@File( copy )( copy_resp );
		if ( !copy_resp ) { throw( CannotCopyBins ) }			
	}]{ nullProcess }
	
	[ copyLaunchers( l_folder )() {
		copy.from = cd + "/" + DIST_FOLDER + "/" + LAUNCHERS_PATH + "/";
		copy.to = l_folder;
		copyDir@File( copy )( copy_resp );
		if ( !copy_resp ) { throw( CannotCopyLaunchers ) }		
	}]{ nullProcess }
}