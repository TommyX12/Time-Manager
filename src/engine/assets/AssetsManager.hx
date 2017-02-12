package engine.assets;

import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.ByteArray;
import openfl.utils.CompressionAlgorithm;
import openfl.Lib;
import sys.*;
import sys.io.*;

/**
 * ...
 * @author TommyX
 */
class AssetsManager
{
	
	public static var execPath:String;
	public static var inPath:String = "";
	public static var outPath:String = "data\\";
	
	public static var pngFormat:String = ".npf";
	public static var oggFormat:String = ".nof";
	public static var wavFormat:String = ".nwf";
	public static var xmlFormat:String = ".nxf";
	
	public static function initialize():Void
	{
		execPath = Sys.executablePath();
		execPath = execPath.substring(0, execPath.lastIndexOf('\\') + 1);
		
		if (!FileSystem.exists(execPath + outPath)) {
			FileSystem.createDirectory(execPath + outPath);
		}
		var contents:Array<String> = FileSystem.readDirectory(execPath);
		for (content in contents) {
			if (content.indexOf(".") == -1) {
				if (content != "manifest" && content != outPath.substring(0, outPath.length - 1)) {
					if (!FileSystem.exists(execPath + outPath + content)) FileSystem.createDirectory(execPath + outPath + content);
					encodeFolder(content + "\\");
					//FileSystem.deleteDirectory(execPath + content + "\\");
				}
			}
		}
		
	}

	public static function decodeBitmapData(path:String):BitmapData
	{
		var inHandle:FileInput = File.read(execPath + outPath + path + pngFormat);
		var byteArray:ByteArray = new ByteArray();
		byteArray.writeBytes(inHandle.readAll());
		byteArray.uncompress(CompressionAlgorithm.GZIP);
		var handler:BitmapData = BitmapData.loadFromBytes(byteArray);
		byteArray.clear();
		return handler;
	}
	
	public static function decodeMusic(path:String):Sound
	{
		var inHandle:FileInput = File.read(execPath + outPath + path + oggFormat);
		var byteArray:ByteArray = new ByteArray();
		byteArray.writeBytes(inHandle.readAll());
		byteArray.uncompress(CompressionAlgorithm.GZIP);
		var handler:Sound = new Sound();
		handler.loadCompressedDataFromByteArray(byteArray, byteArray.length, true);
		byteArray.clear();
		return handler;
	}
	
	public static function decodeSound(path:String):Sound
	{
		var inHandle:FileInput = File.read(execPath + outPath + path + wavFormat);
		var byteArray:ByteArray = new ByteArray();
		byteArray.writeBytes(inHandle.readAll());
		byteArray.uncompress(CompressionAlgorithm.GZIP);
		var handler:Sound = new Sound();
		handler.loadCompressedDataFromByteArray(byteArray, byteArray.length, false);
		byteArray.clear();
		return handler;
	}
	
	public static function decodeXml(path:String):String
	{
		var inHandle:FileInput = File.read(execPath + outPath + path + xmlFormat);
		var byteArray:ByteArray = new ByteArray();
		byteArray.writeBytes(inHandle.readAll());
		byteArray.uncompress(CompressionAlgorithm.GZIP);
		var handler:String = byteArray.toString();
		byteArray.clear();
		return handler;
	}
	
	public static function encodeFolder(path:String):Void
	{
		var absPath:String = execPath + inPath + path;
		var contents:Array<String> = FileSystem.readDirectory(absPath);
		if (contents != null){
			for (content in contents) {
				if (content.indexOf(".") != -1) {
					var fileType:String = content.substring(content.lastIndexOf("."), content.length);
					switch (fileType) 
					{
						case ".png":
							encodePng(path+content);
						case ".ogg":
							encodeOgg(path+content);
						case ".wav":
							encodeWav(path + content);
						case ".xml":
							encodeXml(path + content);
						default:
							copy(path+content);
					}
				}
				else {
					if (!FileSystem.exists(execPath + outPath + path + content)) FileSystem.createDirectory(execPath + outPath + path + content);
					encodeFolder(path + content + "\\");
				}
			}
		}
	}
	
	public static function copy(path:String):Void
	{
		trace("Copying file at [" + path + "]: ... ");
		File.copy(execPath + inPath + path, execPath + outPath + path);
		trace("... Done.");
	}
	
	public static function encodePng(path:String):Void
	{
		trace("Encoding .png file at [" + path + "]: ... ");
		var inHandle:FileInput = File.read(execPath + inPath + path);
		var byteArray:ByteArray = new ByteArray();
		var outHandle:FileOutput = File.write(execPath + outPath + path.substring(0, path.lastIndexOf(".")) + pngFormat, true);
		byteArray.writeBytes(inHandle.readAll());
		byteArray.compress(CompressionAlgorithm.GZIP);
		outHandle.writeString(byteArray.toString());
		outHandle.close();
		trace("... Done.");
	}
	
	public static function encodeOgg(path:String):Void
	{
		trace("Encoding .ogg file at [" + path + "]: ... ");
		var inHandle:FileInput = File.read(execPath + inPath + path);
		var byteArray:ByteArray = new ByteArray();
		var outHandle:FileOutput = File.write(execPath + outPath + path.substring(0, path.lastIndexOf(".")) + oggFormat, true);
		byteArray.writeBytes(inHandle.readAll());
		byteArray.compress(CompressionAlgorithm.GZIP);
		outHandle.writeString(byteArray.toString());
		outHandle.close();
		trace("... Done.");
	}
	
	public static function encodeWav(path:String):Void
	{
		trace("Encoding .wav file at [" + path + "]: ... ");
		var inHandle:FileInput = File.read(execPath + inPath + path);
		var byteArray:ByteArray = new ByteArray();
		var outHandle:FileOutput = File.write(execPath + outPath + path.substring(0, path.lastIndexOf(".")) + wavFormat, true);
		byteArray.writeBytes(inHandle.readAll());
		byteArray.compress(CompressionAlgorithm.GZIP);
		outHandle.writeString(byteArray.toString());
		outHandle.close();
		trace("... Done.");
	}
	
	public static function encodeXml(path:String):Void
	{
		trace("Encoding .xml file at [" + path + "]: ... ");
		var inHandle:FileInput = File.read(execPath + inPath + path);
		var byteArray:ByteArray = new ByteArray();
		var outHandle:FileOutput = File.write(execPath + outPath + path.substring(0, path.lastIndexOf(".")) + xmlFormat, true);
		byteArray.writeBytes(inHandle.readAll());
		byteArray.compress(CompressionAlgorithm.GZIP);
		outHandle.writeString(byteArray.toString());
		outHandle.close();
		trace("... Done.");
	}
	
}