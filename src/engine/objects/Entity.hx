package engine.objects;

import engine.utils.Convert;
import openfl.display.Sprite;
import openfl.events.Event;
import engine.NRFGame;
import engine.NRFDisplay;
import openfl.geom.Point;
import openfl.display.DisplayObjectContainer;
import engine.display.Screen;

/**
 * ...
 * @author TommyX
 */
class Entity extends Sprite
{
	public var stringID:String = "Entity";
	public var nameID:String = "";
	
	public var screen:Screen;

	public function new(screen:Screen) 
	{
		super();
		this.screen = screen;
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	public function remove():Void
	{
		removed();
		
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
	}
	
	private function onAddedToStage(event:Event):Void
	{
		added();
		
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(event:Event):Void
	{
		backgroundUpdate();
		if (screen.paused == false){
			update();
		}
	}
	
	private function added():Void
	{
		//override
	}
	
	private function removed():Void
	{
		//override
	}
	
	private function update():Void 
	{
		//override
	}
	
	private function backgroundUpdate():Void
	{
		//override
	}
	
	public function centerPos(global:Bool = false):Void
	{
		if (global) {
			if (this.parent != null) {
				var point:Point = this.parent.globalToLocal(new Point(NRFDisplay.currentWidth / 2, NRFDisplay.currentHeight / 2));
				x = point.x;
				y = point.y;
			}
		}
		else {
			x = NRFDisplay.centerWidth;
			y = NRFDisplay.centerHeight;
		}
	}
	
	public override function toString():String
	{
		return stringID + "-" + nameID + " x:" + Convert.string(x) + " y:" + Convert.string(y);
	}
	
}