package engine.display;

import openfl.display.Sprite;
import openfl.events.Event;

/**
 * ...
 * @author TommyX
 */
class RenderTarget extends Sprite
{
	public var displayList:Array<AtlasDisplay>;
	public var viewport(default, null):Viewport;
	public var noclear:Bool;
	
	public function new(viewport:Viewport, noclear:Bool=false) 
	{
		super();
		displayList = new Array<AtlasDisplay>();
		this.viewport = viewport;
		this.noclear = noclear;
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(event:Event):Void
	{
		if (!noclear){
			this.graphics.clear();
		}
		for (atlasDisplay in displayList) {
			atlasDisplay.update();
			atlasDisplay.render();
		}
	}
	
	public function addDisplay(atlasDisplay:AtlasDisplay):Void
	{
		displayList.push(atlasDisplay);
	}
	
}