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
include "time.iol"

include "inst_interface.iol"

outputPort OSInst{
Interfaces: InstInterface
}

define setJHProc
{
	getDJH@OSInst()( djh );
	if ( !nonStop ) {
		print@Console(
		"\nInsert the path for the environment variable " + JOLIE_HOME + ".\n"
		+ JOLIE_HOME + " indicates the directory in which the Jolie"
		+ " libraries will be installed."
		+ "\n[press Enter to use the default value: " + djh + "]\nPlease note that using spaces in paths may cause problems.\n\n > "
		)();
		in( jh );
		trim@StringUtils( jh )( jh );
		if ( jh == "" ) {
			jh = djh
		}	
	} else {
		jh = djh
	};
	normalisePath@OSInst( jh )( jh )
}

define setLPProc
{
	getDLP@OSInst()( dlp );
	if ( !nonStop ) {
		print@Console(
			"\nInsert the installation path for the Jolie launcher executables\n" +
			"[press Enter to use the default value: " + dlp + "]\nPlease note that using spaces in paths may cause problems.\n\n > "
		)();
		in( lp );
		trim@StringUtils( lp )( lp );
		if ( lp == "" ) {
			lp = dlp
		}
	} else {
		lp = dlp
	};
	normalisePath@OSInst( lp )( lp )
}

/* 
 * Make command line flags setting possible in a abitrary way, after the first argument (reserved for OS choice).
 * Certain flags (such as the help flag) may have a higher priority than others and thus override the actions of other flags. 
 * When flags are not recognized the help message is shown, and the installation process is skipped. 
 */ 
define getArguments
{
	for ( i = 1, i < #args, ++i ) {
		if ( args[i] == "-y" || args[i] == "/y" ) {
			nonStop = true
		} else if ( args[i] == "-h" || args[i] == "--help" || args[i] == "/h" || args[i] == "/help" ) {
			showHelp = true	
		} else {
			// Argument not understood
			showHelp = true
		}
	}
}

main
{
	// sets the installer for this OS
	eInfo.type = "Jolie";
	if( args[0] == "macos" || args[0] == "linux" ) {
		args[0] = "nix"
	};
	getArguments;

	if (!showHelp) {
		if ( nonStop ) {
			println@Console("Starting install in non-stop; non-interactive mode.\n")()	
		};

		eInfo.filepath = args[0] + "_installer.ol";
		loadEmbeddedService@Runtime( eInfo )( OSInst.location );

		// unzipDist@OSInst()();

		registerForInput@Console()();
		setJHProc;
		
		
		exists@File( jh )( exists );
		if ( exists ) {
			if ( !nonStop ) {
				// interactive 'normal' install mode 
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
					deleteDir@OSInst( jh )();
					println@Console( "\nDirectory " + jh + " does not exist. It has now been created." )();
					mkdir@OSInst( jh )()
				}	
			} else {
				// non-stop, non-interactive install mode
				print@Console(
					"\nDirectory " + jh + " already exists.\n\n"
				)()
			}
		} else {
			println@Console( "\nDirectory " + jh + " does not exist. It has now been created." )();
			mkdir@OSInst( jh )()
		};

		
		install ( CannotCopyBins => 
			sleep@Time( 1000 )();
			println@Console( main.CannotCopyBins.message )();
			throw( FaultInstallation )
		);
		copyBins@OSInst( jh )();
			
		println@Console( "\nJolie libraries installed in path " + jh + "\n" )();

		setLPProc;
		isDirectory@File( lp )( exists );
		if ( !exists ) {
			println@Console( "\nDirectory " + lp + " does not exist. It has now been created." )();
			mkdir@OSInst( lp )()
		};
		
		install ( CannotCopyInstallers => 
			sleep@Time( 1000 )();
			println@Console( main.CannotCopyInstallers.message )(); 
			throw( FaultInstallation )
		);
		copyLaunchers@OSInst( lp )();

		println@Console( "\nJolie launcher executables installed in path " + lp + "\n" )();

		installationFinished@OSInst( jh )();

		if ( nonStop ) {
			println@Console("\nJolie is installed.")()
		} else {
			println@Console("\nJolie is installed. Try running 'jolie' under a new shell")()
		}
	} else {
		println@Console(
			"Jolie installer\n\nUsage:\njava -jar <Jolie installer jar> [options...]\n\n" +
			"Following options are available:"
			)();
		if (args[0] == "nix") {
			println@Console( 
				"    -h | --help\t Show this help message\n" +
				"    -y\t Run the installer in non-interactive mode (Note: This does not set the environmental variable JOLIE_HOME, do this manually)\n" 
			)()
		} else {
			// windows cmd
			println@Console( 
				"    /h | /help\t Show this help message\n" +
				"    /y\t Run the installer in non-interactive mode\n" 
			)()
		};
		println@Console(
			"See http://http://jolie-lang.org/downloads.html for further details"
			)()
	}
}
