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

include "console.iol"
include "runtime.iol"
include "exec.iol"
include "string_utils.iol"

include "inst_interface.iol"

outputPort OSInst{  
	Interfaces: InstInterface
}

define setJHProc
{
  getDJH@OSInst()( djh );
  println@Console( "Do you want to set " + JOLIE_HOME + " to default [y/any]" )();
  println@Console( " -> " + djh )();
  registerForInput@Console()();
  in( c );
  if( c == "y" ) {
    jh = djh
  } else {
  	println@Console( "insert the path for JOLIE_HOME" )();
  	registerForInput@Console()();
  	in( jh )
  };
  setJH@OSInst( jh )()
}

define setLPProc
{
	getDLP@OSInst()( dlp );
	println@Console( "The default path for Jolie launchers is " + "\n" + dlp + 
		"\nDo you want to copy the launchers in the default path [y/any]" )();
	registerForInput@Console()();
  in( c );
  if( c == "y" ) {
    lp = djh
  } else {
  	println@Console( "insert the path for JOLIE_HOME" )();
  	registerForInput@Console()();
  	in( lp )
  }
}

main
{
	// sets the installer for this OS
	eInfo.type = "Jolie";
  eInfo.filepath = args[0] + "_installer.ol";
  loadEmbeddedService@Runtime( eInfo )( OSInst.location );

  unzipDist@OSInst()();

	setJHProc;
	copyBins@OSInst( jh )( exitCode );

 //  print@Console( "\nPress any key to continue..." )();
	// registerForInput@Console()();
	// in()

	// setLPProc;
	// copyLaunchers;

	println@Console( "Jolie is installed, try running 'jolie' under a new shell" )()
}

