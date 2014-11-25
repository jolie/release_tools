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

include "console.iol"
include "runtime.iol"
include "exec.iol"
include "file.iol"
include "string_utils.iol"

include "inst_interface.iol"

outputPort OSInst{  
Interfaces: InstInterface
}

define setJHProc
{
	getDJH@OSInst()( djh );
	print@Console(
		"\nInsert the path for the environment variable " + JOLIE_HOME + ".\n"
		+ JOLIE_HOME + " indicates the directory in which the Jolie"
		+ " libraries will be installed."
		+ "\n[press Enter to use the default value: " + djh + "]\n\n > "
	)();
	in( jh );
	trim@StringUtils( jh )( jh );
	if ( jh == "" ) {
		jh = djh
	};
	normalisePath@OSInst( jh )( jh )
}

define setLPProc
{
	getDLP@OSInst()( dlp );
	print@Console(
		"\nInsert the installation for the Jolie launcher executables\n" + 
		"[press Enter to use the default value: " + dlp + "]\n\n > "
	)();
	in( lp );
	trim@StringUtils( lp )( lp );
	if ( lp == "" ) {
		lp = dlp
	};
	normalisePath@OSInst( lp )( lp )
}

main
{  
	// sets the installer for this OS
	eInfo.type = "Jolie";
	if( args[0] == "macos" || args[0] == "linux" ) {
		args[0] = "nix"
	};
	eInfo.filepath = args[0] + "_installer.ol";
	loadEmbeddedService@Runtime( eInfo )( OSInst.location );

	// unzipDist@OSInst()();

	registerForInput@Console()();
	setJHProc;
	exists@File( jh )( exists );
	if ( exists ) {
		print@Console(
			"\nThe target installation directory " + jh + " already exists.\n"
			+ "Delete it before proceeding? [y/N]\n\n > "
		)();
		in( decision );
		while( decision != "y" && decision != "" && decision != "n" ) {
			print@Console( "\nOption not understood, please choose y or n.\n\n >" )();
			in( decision )
		};
		if ( decision == "y" ) {
			println@Console( "\nDeleting directory " + jh )();
			deleteDir@OSInst( jh )()
		}
	};
	copyBins@OSInst( jh )();
	println@Console( "\nJolie libraries installed in path " + jh + "\n" )();

	setLPProc;
	isDirectory@File( lp )( exists );
	if ( !exists ) {
		println@Console( "\nDirectory " + lp + " does not exist. It has now been created." )();
		mkdir@OSInst( lp )()
	};
	copyLaunchers@OSInst( lp )();
	
	println@Console( "\nJolie launcher executables installed in path " + jh + "\n" )();
	
	installationFinished@OSInst( jh )();

	println@Console( "\nJolie is installed. Try running 'jolie' under a new shell [press Enter to exit]" )()
}

