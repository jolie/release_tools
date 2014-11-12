constants
{
	JOLIE_HOME = "JOLIE_HOME",
	DIST_FOLDER = "dist",
	DIST_PACKAGE_PATH = "../dist.zip",
	JOLIE_FOLDER = "jolie"
}

interface InstInterface {
  RequestResponse: 	getJH( void )( any ),
  									getDJH( void )( string ),
  									getDLP( void )( string ),
  									setJH( string )( void ),
  									unzipDist( void )( void ),
  									copyBins( string )( void )
}