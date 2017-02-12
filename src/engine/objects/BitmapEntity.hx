package engine.objects;

import engine.display.Screen;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;

/**
 * ...
 * @author TommyX
 */
class BitmapEntity extends Entity
{

	public var bitmap(default,null):Bitmap;
	@:isVar public var bitmapData(default, set):BitmapData;
	
	function set_bitmapData(_bitmapData){
		bitmap.bitmapData = _bitmapData;
		return bitmapData = _bitmapData;
	}
	
	public function new(screen:Screen, bitmapData:BitmapData) 
	{
		super(screen);
		stringID = "BitmapEntity"; //use the string to bitmapData system
		bitmap = new Bitmap(bitmapData);
		this.bitmapData = bitmapData;
	}
	
	private override function onAddedToStage(event:Event):Void
	{
		bitmap.smoothing = NRFDisplay.bitmapSmoothing;
		bitmap.x = -Math.round(bitmap.width / 2);
		bitmap.y = -Math.round(bitmap.height / 2);
		addChild(bitmap);
		
		added();
		
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

}