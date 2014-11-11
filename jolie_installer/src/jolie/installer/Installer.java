/***************************************************************************
 *   Copyright 2014 (C) by Fabrizio Montesi <famontesi@gmail.com>          *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 *                                                                         *
 *   For details about the authors of this software, see the AUTHORS file. *
 ***************************************************************************/

package jolie.installer;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.nio.channels.Channels;
import jolie.Jolie;
import jolie.util.Helpers;

/**
 *
 * @author Fabrizio Montesi
 */
public class Installer
{
	private static void exec( File dir, String... args )
		throws IOException, InterruptedException
	{
		ProcessBuilder builder = new ProcessBuilder( args );
		builder.directory( dir );
		Process p = builder.start();
		p.waitFor();
		if ( p.getErrorStream() != null ) {
			int len = p.getErrorStream().available();
			if ( len > 0 ) {
				char[] buffer = new char[ len ];
				BufferedReader reader = new BufferedReader( new InputStreamReader( p.getErrorStream() ) );
				reader.read( buffer, 0, len );
				System.out.println( new String( buffer ) );
			}
		}
		p.destroy();
	}
	
	private File createTmpDir()
		throws IOException
	{
		File tmp = File.createTempFile( "jolie_installer_tmp", "" );
		tmp.delete();
		tmp.mkdir();
		//tmp.deleteOnExit();
		return tmp;
	}
	
	private void copyDistZip( File parentDir )
		throws IOException
	{
		InputStream is = JolieInstaller.class.getClassLoader().getResourceAsStream( "dist.zip" );
		File distTmp = new File( parentDir, "dist.zip" );
		distTmp.createNewFile();
		new FileOutputStream( distTmp ).getChannel().transferFrom( Channels.newChannel( is ), 0, Long.MAX_VALUE );
	}
	
	private void copyInstallerScript( File parentDir )
		throws IOException
	{
		InputStream is = JolieInstaller.class.getClassLoader().getResourceAsStream( "scripts/installer.ol" );
		File distTmp = new File( parentDir, "installer.ol" );
		distTmp.createNewFile();
		new FileOutputStream( distTmp ).getChannel().transferFrom( Channels.newChannel( is ), 0, Long.MAX_VALUE );
	}

	private File createTmpDist()
		throws IOException, InterruptedException
	{
		File tmp = createTmpDir();
		copyDistZip( tmp );
		copyInstallerScript( tmp );
		exec( tmp, "unzip", "dist.zip" );
		return new File( tmp, "dist" );
	}
	
	private String getOSName( ClassLoader cl )
		throws ClassNotFoundException, NoSuchMethodException,
		IllegalAccessException, InvocationTargetException
	{
		Class<?> jolieClass = cl.loadClass( "jolie.util.Helpers" );
		Method m = jolieClass.getMethod( "getOperatingSystemType" );
		Object obj = m.invoke( null );
		return obj.toString();
	}
		
	public void run()
		throws IOException, InterruptedException,
		ClassNotFoundException, NoSuchMethodException,
		IllegalAccessException, InvocationTargetException
	{
		File tmp = createTmpDist();
		String jolieDir = new File( tmp, "jolie" ).getAbsolutePath();
		char fs = File.separatorChar;
		
		URL[] urls = new URL[] { new URL( "file:" + jolieDir + fs + "jolie.jar" ), new URL( "file:" + jolieDir + fs + "lib" + fs + "libjolie.jar" ) };
		ClassLoader cl = new URLClassLoader( urls, Installer.class.getClassLoader() );
		Class<?> jolieClass = cl.loadClass( "jolie.Jolie" );
		Method m = jolieClass.getMethod( "main", String[].class );
		m.invoke(
			null,
			(Object) new String[] {
				"-l",
				jolieDir + fs + "lib" + fs + "*:"
				+ jolieDir + fs + "lib:"
				+ jolieDir + fs + "javaServices" + fs + "*:"
				+ jolieDir + fs + "extensions" + fs + "*",
				"-i",
				jolieDir + fs + "include",
				tmp.getParent() + fs + "installer.ol",
				getOSName( cl ).toLowerCase()
			}
		);
	}
}
