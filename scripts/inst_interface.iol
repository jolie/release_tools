constants
{
	JOLIE_HOME = "JOLIE_HOME",
	DIST_FOLDER = "dist",
	JOLIE_FOLDER = "jolie"
}

interface InstInterface {
  RequestResponse: 	getJH( void )( any ),
  									getDJH( void )( string ),
  									getDLP( void )( string ),
  									setJH( string )( void ),
  									unzipDist( void )( void ),
  									copyBins( string )( void ),
  									copyLaunchers( string )( bool ),
}