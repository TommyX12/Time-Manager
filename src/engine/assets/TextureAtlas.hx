package engine.assets;

import openfl.display.BitmapData;
import openfl.display.Tilesheet;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import engine.utils.Util;

using StringTools;

/**
 * A cross-targets Tilesheet container, with animation and trimming support
 *
 * - animations are matched by name (startsWith) and cached after 1st request,
 * - rect: marks the actual pixel content of the spritesheet that should be displayed for a sprite,
 * - size: original (before trimming) sprite dimensions are indicated by the size's (width,height); 
 *         rect offset inside the original sprite is indicated by size's (left,top).
 *
 * @author Philippe / http://philippe.elsass.me
 */
class TextureAtlas extends Tilesheet
{
	public var img:BitmapData;
	public var scale:Float;
	public var defs:Array<String>;
	public var sizes:Array<Rectangle>;
	public var rects:Array<Rectangle>;
	public var centers:Array<Point>;

	var anims:Map<String,Array<Int>>;

	public function new(img:BitmapData, textureScale:Float = 1.0)
	{
		super(img);
		this.img = img;
		scale = 1/textureScale;
		
		defs = new Array<String>();
		anims = new Map < String, Array<Int> > ();
		sizes = new Array<Rectangle>();
		rects = new Array<Rectangle>();
		centers = new Array<Point>();
	}

	public function addDefinition(name:String, size:Rectangle, rect:Rectangle, center:Point)
	{
		defs.push(name);
		sizes.push(size);
		rects.push(rect);
		centers.push(center);
		addTileRect(rect, center);
	}

	public function getAnim(name:String):Array<Int>
	{
		if (anims.exists(name))
			return anims.get(name);
		var indices = new Array<Int>();
		for (i in 0...defs.length)
		{
			if (defs[i].startsWith(name)) 
				indices.push(i);
		}
		anims.set(name, indices);
		return indices;
	}

	inline public function getSize(indice:Int):Rectangle
	{
		if (indice < sizes.length) return sizes[indice];
		else return new Rectangle();
	}

	static public function createFromAssets(fileNames:Array<String>, padding:Int=0, spacing:Int=0)
	{
		var names:Array<String> = [];
		var images:Array<BitmapData> = [];
		for(fileName in fileNames)
		{
			var name = fileName.split("/").pop();
			name = name.split(".")[0];
			var image = AssetsManager.decodeBitmapData(fileName);
			names.push(name);
			images.push(image);
		}
		return createFromImages(names, images, padding, spacing);
	}

	static public function createFromImages(names:Array<String>, images:Array<BitmapData>, padding:Int=0, spacing:Int=0)
	{
		var width = 0;
		var height = padding;
		for(image in images)
		{
			if (image.width + padding*2 > width) width = image.width + padding*2;
			height += image.height + spacing;
		}
		height -= spacing;
		height += padding;

		var img = new BitmapData(Util.closestPow2(width), Util.closestPow2(height), true, 0);
		var sheet = new TextureAtlas(img);

		var pos = new Point(padding, padding);
		for(i in 0...images.length)
		{
			var image = images[i];
			img.copyPixels(image, image.rect, pos, null, null, true);
			var rect = new Rectangle(padding, pos.y, image.width, image.height);
			var center = new Point(image.width/2, image.height/2);
			sheet.addDefinition(names[i], image.rect, rect, center);
			pos.y += image.height + spacing;
		}
		return sheet;
	}
	
}
