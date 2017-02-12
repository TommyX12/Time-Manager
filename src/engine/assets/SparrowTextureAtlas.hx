package engine.assets;

import engine.assets.TextureAtlas;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import engine.utils.Convert;

/**
parrow spritesheet parser for TileLayer
 * - supports animations
 * - supports sprite trimming
 * - does NOT support sprite rotation
 * @author Philippe / http://philippe.elsass.me
 */
class SparrowTextureAtlas extends TextureAtlas
{

	public function new(img:BitmapData, xml:String, textureScale:Float = 1.0) 
	{
		super(img, textureScale);
		
		var ins = new Point(0,0);
		var x = new haxe.xml.Fast( Xml.parse(xml).firstElement() );

		for (texture in x.nodes.SubTexture)
		{
			var name = texture.att.name;
			var rect = new Rectangle(
				Convert.float(texture.att.x), Convert.float(texture.att.y),
				Convert.float(texture.att.width), Convert.float(texture.att.height));
			
			var size = if (texture.has.frameX) // trimmed
					new Rectangle(
						Convert.int(texture.att.frameX), Convert.int(texture.att.frameY),
						Convert.int(texture.att.frameWidth), Convert.int(texture.att.frameHeight));
				else 
					new Rectangle(0, 0, rect.width, rect.height);
			
			//trace([name, rect.x, rect.y, rect.width, rect.height, size.x, size.y, size.width, size.height]);
			
			var center = new Point((size.x + size.width / 2), (size.y + size.height / 2));
			addDefinition(name, size, rect, center);
		}
	}

}
