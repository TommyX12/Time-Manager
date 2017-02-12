package engine.utils;

/**
 * ...
 * @author TommyX
 */
class Convert
{
	
	public static function is(v:Dynamic, t:Dynamic):Bool
	{
		return Std.is(v, t);
	}

	public static function int(value:Dynamic):Int
	{
		if (Std.is(value, Float)) {
			return Math.round(value);
		}
		else if (Std.is(value, Int)) {
			return value;
		}
		return Std.parseInt(value);
	}
	
	public static function float(value:Dynamic):Float
	{
		if (Std.is(value, Int) || Std.is(value, Float)) {
			return value;
		}
		return Std.parseFloat(value);
	}
	
	public static function string(value:Dynamic):String
	{
		return Std.string(value);
	}
	
	public static function rad(deg:Float):Float 
	{
		return deg / 180 * Math.PI;
	}
	
	public static function deg(rad:Float):Float 
	{
		return rad / Math.PI * 180;
	}
	
	public static function second(frame:Float):Float
	{
		return frame / NRFDisplay.fps;
	}
	
	public static function frame(second:Float):Float
	{
		return second * NRFDisplay.fps;
	}
	
	public static function color(r:Int, g:Int, b:Int, a:Int=-1):Int
	{
		return a == -1 ? r << 16 | g << 8 | b : r << 24 | g << 16 | b << 8 | a;
	}
	
	public static function colorFloat(r:Float, g:Float, b:Float, a:Float=-1):Int
	{
		return a == -1 ? int(r*255) << 16 | int(g*255) << 8 | int(b*255) : int(r*255) << 24 | int(g*255) << 16 | int(b*255) << 8 | int(a*255);
	}
	
}