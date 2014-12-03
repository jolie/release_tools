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
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.lang.reflect.InvocationTargetException;
import java.nio.channels.Channels;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 *
 * @author Fabrizio Montesi
 */
public class Installer {

	static final String windows = "windows";
	static final String unix = "unix";
	private final static int BUFFER_SIZE = 1024;
		
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
//		File tmp = new File( System.getProperty("user.home") + File.separator + "Desktop" + File.separator + "jolie_installer" );
		tmp.delete();
		tmp.mkdir();
		tmp.deleteOnExit();
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
		throws IOException, InterruptedException
	{
		InputStream is = JolieInstaller.class.getClassLoader().getResourceAsStream( "installer.zip" );
		File distTmp = new File( parentDir, "installer.zip" );
		distTmp.createNewFile();
		new FileOutputStream( distTmp ).getChannel().transferFrom( Channels.newChannel( is ), 0, Long.MAX_VALUE );
	}

	private File createTmpDist()
		throws IOException, InterruptedException, Exception
	{
		File tmp = createTmpDir();
		copyDistZip( tmp );
//		exec( tmp, "unzip", "dist.zip" );
		unzip( tmp.getAbsolutePath(), "dist.zip" );
		copyInstallerScript( tmp );
//		exec( tmp, "unzip", "installer.zip" );
		unzip( tmp.getAbsolutePath(), "installer.zip" );
		return new File( tmp, "dist" );
	}
	
//	private String getLauncher( File lsf ) throws IOException, FileNotFoundException {
//		int len;
//		char[] chr = new char[4096];
//		final StringBuffer buffer = new StringBuffer();
//		final FileReader reader = new FileReader( lsf );
//		try {
//			while ( ( len = reader.read( chr ) ) > 0 ) {
//				buffer.append(chr, 0, len);
//			}
//		} finally {
//			reader.close();
//		}
//		return buffer.toString();
//	}
	
//	private String getOSName( ClassLoader cl )
//		throws ClassNotFoundException, NoSuchMethodException,
//		IllegalAccessException, InvocationTargetException
//	{
//		Class<?> jolieClass = cl.loadClass( "jolie.util.Helpers" );
//		Method m = jolieClass.getMethod( "getOperatingSystemType" );
//		Object obj = m.invoke( null );
//		return obj.toString();
//	}
//	
	// MODIFY THIS METHOD TO READ FROM THE PROPER JOLIE LAUNCHER AND MODIFY IT
	// THE METHOD getLauncher ABOVE IS A STUB
	private String getLauncher( String os, String jolieHome ){
		
		if( os.equals( "windows" ) ){
			jolieHome = jolieHome + File.separator;
			return "java -ea:jolie... -ea:joliex... -Xmx1G -jar" + jolieHome + "jolie.jar -l "
					+ ".\\lib\\*;" + jolieHome + "lib;" + jolieHome + "javaServices\\*;"
					+ jolieHome + "extensions\\* -i " + jolieHome + "include";
		} else {
			return "java -ea:jolie... -ea:joliex... -Xmx1G "
					+ "-Djava.rmi.server.codebase=file:/" + jolieHome + "/extensions/rmi.jar -cp "
					+ jolieHome + "/lib/libjolie.jar:" + jolieHome + "/jolie.jar jolie.Jolie "
					+ "-l ./lib/*:" + jolieHome + "/lib:" + 
					jolieHome + "/javaServices/*:" + jolieHome + "/extensions/* "
					+ "-i " + jolieHome + "/include";
		}
	}
	
	private void runCmd( String cmd ) throws InterruptedException {

	try {
		String line;
		final Process process = Runtime.getRuntime().exec( cmd );
		final InputStream stderr = process.getErrorStream();
		final InputStream stdin = process.getInputStream();
		final OutputStream stdout = process.getOutputStream();
		
		ExecutorService e1 = Executors.newSingleThreadExecutor();
		ExecutorService e2 = Executors.newSingleThreadExecutor();
		ExecutorService e3 = Executors.newSingleThreadExecutor();
		
		e1.execute( new Runnable() {
			@Override
			public void run() {
				try {	
					BufferedReader br = new BufferedReader( new InputStreamReader( System.in ));
					BufferedWriter bw = new BufferedWriter(new OutputStreamWriter( stdout ));

					String l;
					while( ( l = br.readLine() ) != null ){
						bw.write( l );
						bw.write( "\n" );
						bw.flush();
					}
					bw.close();
					br.close();
				} catch (IOException ex) {
//					Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
				}
			}
		});
		
		e2.execute( new Runnable() {
			@Override
			public void run() {
				try {
					BufferedReader br = new BufferedReader( new InputStreamReader(stdin) );
					int c;
					while( ( c = br.read() ) != -1 ){
						System.out.print( (char) c );
					}
					br.close();
				} catch (IOException ex) {
//					Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
				}
			}
		});
		
		e3.execute( new Runnable() {
			@Override
			public void run() {
				try {
					BufferedReader br = new BufferedReader( new InputStreamReader( stderr) );
					int c;
					while( ( c = br.read() ) != -1 ){
						System.out.print( (char) c );
					}
					br.close();
				} catch (IOException ex) {
//					Logger.getLogger(Installer.class.getName()).log(Level.SEVERE, null, ex);
				}
			}
		});
		
		process.waitFor();
		e1.shutdown();
		e2.shutdown();
		e3.shutdown();
		process.destroy();
	} catch (IOException err) {
//		err.printStackTrace();
		}
	}
	
	public  void unzip( String targetPath, String zipname ) throws Exception {
	byte[] buffer = new byte[ BUFFER_SIZE ];
	ZipInputStream zipInputStream;
	try {
		zipInputStream = new ZipInputStream(new FileInputStream( targetPath + File.separator + zipname ));				
		ZipEntry zipEntry = zipInputStream.getNextEntry();
		String filename;
		while( zipEntry != null ) {
			filename = zipEntry.getName();
			if ( !zipEntry.isDirectory() ) {
				File newFile = new File( targetPath + File.separator + filename );
				new File(newFile.getParent()).mkdirs();
				FileOutputStream fileOutputStream = new FileOutputStream(newFile);             
				int len;
				while ((len = zipInputStream.read(buffer)) > 0) {
						fileOutputStream.write(buffer, 0, len);
				}
				fileOutputStream.close();   
			}
			zipEntry = zipInputStream.getNextEntry();				
    }
 
	zipInputStream.closeEntry();
   	zipInputStream.close();
				
	} catch( FileNotFoundException ex ) {
		throw new Exception("FileNotFound");
	} catch( IOException ex ) {
			throw new Exception("IOException");
	}
}
	
	private void runJolie( String wdir, String jolieDir ){
		// get the os
		String os = Helpers.getOperatingSystemType().toString().toLowerCase();
//		String ext = "";
//		String replaceVar;
		
//		if ( os.equals( "macos" ) || os.equals( "linux" ) ) {
//			os = "unix";
//		} 
//			else {
//			ext = ".bat";
//		}
		
		try {
			// get the corresponding jolie launcher script
			String cmd = getLauncher( os, jolieDir );
			cmd += " " + wdir + File.separator + "installer.ol " + os;
			runCmd( cmd );
			
		} catch (InterruptedException ex) {
			ex.printStackTrace();
		}
	}
		
	public void run()
		throws IOException, InterruptedException,
		ClassNotFoundException, NoSuchMethodException,
		IllegalAccessException, InvocationTargetException, Exception
	{
		File tmp = createTmpDist();
		String jolieDir = new File( tmp, "jolie" ).getAbsolutePath();
		char fs = File.separatorChar;
		
		runJolie( tmp.getParent(), jolieDir );
		
//		URL[] urls = new URL[] { new URL( "file:" + jolieDir + fs + "jolie.jar" ), new URL( "file:" + jolieDir + fs + "lib" + fs + "libjolie.jar" ) };
//		ClassLoader cl = new URLClassLoader( urls, Installer.class.getClassLoader() );
//		Class<?> jolieClass = cl.loadClass( "jolie.Jolie" );
//		Method m = jolieClass.getMethod( "main", String[].class );
//		m.invoke(
//			null,
//			(Object) new String[] {
//			"-l",
//			jolieDir + fs + "lib" + fs + "*:"
//			+ jolieDir + fs + "lib:"
//			+ jolieDir + fs + "javaServices" + fs + "*:"
//			+ jolieDir + fs + "extensions" + fs + "*",
//			"-i",
//			jolieDir + fs + "include",
//			"--trace",
//			tmp.getParent() + fs + "installer.ol",
//			getOSName( cl ).toLowerCase()
//			}
//		);
	}
}
