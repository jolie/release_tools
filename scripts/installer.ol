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
include "file.iol"
include "string_utils.iol"

include "inst_interface.iol"

outputPort OSInst{  
	Interfaces: InstInterface
}

define setJHProc
{
  getDJH@OSInst()( djh );
  print@Console( "\nInsert the path of " + JOLIE_HOME + ".\n" + 
    JOLIE_HOME + " is where Jolie executables\n" + 
    "and libraries will be installed (e.g., " + djh + ")\n\n > " )();
  registerForInput@Console()();
  in( jh );
 	setJH@OSInst( jh )()
}

define setLPProc
{
	getDLP@OSInst()( dlp );
	print@Console( "Insert the path where you want to copy Jolie launchers" + 
    " (e.g., \"" + dlp + "\")\n\n > " )();
	registerForInput@Console()();
 	in( lp )
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

  setJHProc;
  copyBins@OSInst( jh )();
  println@Console( "Jolie is installed into path \"" + jh + "\"\n" )();

  while( !done ){
   setLPProc;
   copyLaunchers@OSInst( lp )( done )
  };

  println@Console( "Jolie is installed, try running 'jolie' under a new shell" )()
}

