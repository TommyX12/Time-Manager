package engine.display;

import openfl.display.Tilesheet;
import openfl.Lib;

class RenderList
{
	public var list:Array<Float>;
	public var index:Int;
	public var fields:Int;
	public var offsetTransform:Int;
	public var offsetRGB:Int;
	public var offsetAlpha:Int;
	public var flags:Int;
	public var time:Int;
	public var runs:Int;

	public function new() 
	{
		list = new Array<Float>();
		runs = 0;
	}

	public function begin(useTransforms:Bool, useAlpha:Bool, useTint:Bool, blendMode:Int) 
	{
		flags = 0;
		fields = 3;
		if (useTransforms) {
			offsetTransform = fields;
			fields += 4;
			flags |= Tilesheet.TILE_TRANS_2x2;
		}
		else offsetTransform = 0;
		if (useTint) {
			offsetRGB = fields; 
			fields+=3; 
			flags |= Tilesheet.TILE_RGB;
		}
		else offsetRGB = 0;
		if (useAlpha) {
			offsetAlpha = fields; 
			fields++; 
			flags |= Tilesheet.TILE_ALPHA;
		}
		else offsetAlpha = 0;
		if (blendMode != -1) flags |= blendMode;
	}

	public function end()
	{
		if (list.length > index) 
		{
			if (++runs > 60) 
			{
				list.splice(index, list.length - index); // compact buffer
				runs = 0;
			}
			else
			{
				while (index < list.length)
				{
					list[index + 2] = -2.0; // set invalid ID
					index += fields;
				}
			}
		}
	}
}
