package engine.objects;

import engine.display.AtlasDisplay;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.geom.Rectangle;


class AtlasEntity extends AtlasElement
{
	private var _tile:String;
	private var _indice:Int;
	private var size:Rectangle;

	public var bmp:Bitmap;
	
	public var r(default, set_r):Float;
	public var g(default, set_g):Float;
	public var b(default, set_b):Float;
	public var luminance:Float;
	
	@:noCompletion private function set_r(_r:Float):Float 
	{
		return r = Math.min(Math.max(_r,0),1);
	}
	
	@:noCompletion private function set_g(_g:Float):Float 
	{
		return g = Math.min(Math.max(_g,0),1);
	}
	
	@:noCompletion private function set_b(_b:Float):Float 
	{
		return b = Math.min(Math.max(_b,0),1);
	}
	         
	public var color(get_color, set_color):Int;
	@:noCompletion private function get_color():Int 
	{ 
		return Std.int(r * 255.0) << 16
			| Std.int(g * 255.0) << 8
			| Std.int(b * 255.0);
	}
	@:noCompletion private function set_color(value:Int):Int 
	{
		r = (value >> 16) / 255.0;
		g = ((value >> 8) & 0xff) / 255.0;
		b = (value & 0xff) / 255.0;
		return value;
	}

	public function new(layer:AtlasDisplay, tile:String) 
	{
		super(layer);
		stringID = "AtlasEntity";
		r = 1;
		g = 1;
		b = 1;
		luminance = 1;
		_indice = -1;
		this.tile = tile;
	}

	override public function init(layer:AtlasDisplay):Void
	{
		this.layer = layer;
		var indices = layer.tilesheet.getAnim(tile);
		indice = indices[0];
		size = layer.tilesheet.getSize(indice);
	}

	public var tile(get_tile, set_tile):String;
	@:noCompletion private inline function get_tile():String { return _tile; }
	@:noCompletion private function set_tile(value:String):String
	{
		if (_tile != value) {
			_tile = value;
			if (layer != null) init(layer); // update visual
		}
		return value;
	}

	public var indice(get_indice, set_indice):Int;
	@:noCompletion private inline function get_indice():Int { return _indice; }
	@:noCompletion private function set_indice(value:Int)
	{
		if (_indice != value)
		{
			_indice = value;
		}
		return value;
	}

	public var height(get, set):Float;
	@:noCompletion private inline function get_height():Float return size.height * scaleY;
	@:noCompletion private function set_height(value:Float):Float
	{
		scaleY = value / size.height;
		return value;
	}

	public var width(get, set):Float;
	@:noCompletion private inline function get_width():Float return size.width * scaleX;
	@:noCompletion private function set_width(value:Float):Float
	{
		scaleX = value / size.width;
		return value;
	}

}
