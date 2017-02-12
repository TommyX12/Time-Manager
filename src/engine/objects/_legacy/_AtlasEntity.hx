package engine.objects._legacy;

import engine.objects.AtlasEntity;
import engine.objects.Entity;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;

/**
 * ...
 * @author TommyX
 */
class AtlasEntity extends Entity
{
	
	public var elementList(default, null):Array<AtlasEntity>;
	
	@:isVar public var scale(get, set):Float;
	
	public var displayParent:Entity;

	function set_scale(_scale:Float) {
		scaleX = scale;
		scaleY = scale;
		return scale = _scale;
	}
	
	function get_scale() {
		return (scaleX + scaleY) / 2;
	}

	public function new(_parentEntity:Entity, _x:Float = 0, _y:Float = 0, _scale:Float = 1, _rotation:Float = 0, _alpha:Float = 1, _visible:Bool = true) 
	{
		super(_parentEntity, _x, _y, _scale, _scale, _rotation, _alpha, _visible);
		stringID = "AtlasEntity";
		globalTransform = true;
		
		elementList = new Array<AtlasEntity>();
		
		scale = _scale;

	}
	
	public function addElement(element:AtlasEntity):Void
	{
		elementList.push(element);
		element.added();
	}
	
	public function removeElement(element:AtlasEntity):Void
	{
		elementList.remove(element);
		element.removed();
	}
	
	private override function onEnterFrame(event:Event):Void 
	{
		backgroundUpdate();
		if (this.displayParent != null) {
			if (this.displayParent.globalTransform) {
				globalScale = scale * this.displayParent.globalScale;
				globalRotation = rotation + this.displayParent.globalRotation;
				globalAlpha = alpha * this.displayParent.globalAlpha;
				globalVisible = this.displayParent.globalVisible ? visible : false;
			}
			else {
				globalParent = this.parent;
				globalScale = scale;
				globalRotation = rotation;
				globalAlpha = alpha;
				globalVisible = visible;
				while (globalParent != screen && globalVisible) {
					globalScale *= (globalParent.scaleX + globalParent.scaleY) / 2;
					globalRotation += globalParent.rotation;
					globalAlpha *= globalParent.alpha;
					globalVisible = globalParent.visible;
					globalParent = globalParent.parent;
				}
			}
		}
		if (screen.paused == false) {
			update();
		}
		for (element in elementList) {
			element.uploadData();
		}
		parallaxUpdate();
	}
	
	private override function onAddedToStage(event:Event):Void 
	{
		displayParent = cast (parent, Entity);
		
		added();
		
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	public override function remove():Void
	{
		removed();
		
		displayParent = null;
		globalVisible = false;
		for (element in elementList) {
			removeElement(element);
		}
		
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
	}
	
}