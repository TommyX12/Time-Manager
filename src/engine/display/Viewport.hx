package engine.display;

import openfl.events.Event;
import openfl.display.Sprite;

class Viewport extends Sprite {
	public var time:Float = 0;
	
	public var screen:Screen;
	
	public var main:RenderTarget;

	public function new(screen:Screen){
		super();
		
		mouseEnabled = false;
		mouseChildren = false;
		
		this.screen = screen;
		
		main = new RenderTarget(this);
		
		initialize();
		
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function initialize():Void
	{
		this.addChild(main);
	}
	
	private function onEnterFrame(event:Event):Void
	{
		time = time > 108000 ? 0 : time+1;
	}
	
}