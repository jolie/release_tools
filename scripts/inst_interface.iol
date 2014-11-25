constants
{
	JOLIE_HOME = "JOLIE_HOME",
	DIST_FOLDER = "dist",
	JOLIE_FOLDER = "jolie"
}

interface InstInterface {
RequestResponse:
	getDJH( void )( string ),
	getDLP( void )( string ),
	copyBins( string )( void ),
	copyLaunchers( string )( void ),
	mkdir( string )( void ),
	deleteDir( string )( void ),
	normalisePath( string )( string ),
	installationFinished( string )( void )
}