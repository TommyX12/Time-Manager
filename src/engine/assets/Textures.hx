package engine.assets;
import openfl.display.BitmapData;
import openfl.Assets;

/**
 * ...
 * @author TommyX
 */

class Textures
{
	private static var textureLibrary:Map<String,BitmapData> = new Map<String,BitmapData>();
	private static var atlasLibrary:Map<String,TextureAtlas> = new Map<String,TextureAtlas>();
	
	public static function getTexture(name:String):BitmapData
	{
		return textureLibrary.get(name);
	}
	
	public static function getAtlas(name:String):TextureAtlas
	{
		return atlasLibrary.get(name);
	}
	
	public static function newTexture(name:String, texture:BitmapData):Void
	{
		textureLibrary.set(name, texture);
	}
	
	public static function newAtlas(name:String, textureAtlas:TextureAtlas):Void
	{
		atlasLibrary.set(name, textureAtlas);
	}
	
	public static function newSparrowAtlas(name:String, textureAtlasPath:String, auto_quality:Bool=true):Void
	{
		var ext:String = "";
		if (auto_quality) ext = "_" + NRFDisplay.textureQuality;
		var tex_scale:Float = 1;
		if (auto_quality) tex_scale = NRFDisplay.textureScale;
		atlasLibrary.set(name, new SparrowTextureAtlas(AssetsManager.decodeBitmapData(textureAtlasPath + ext), AssetsManager.decodeXml(textureAtlasPath + ext), tex_scale));
	}
	
}