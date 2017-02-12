package engine.display;

import engine.utils.Vec2D;
import engine.utils.Vec2DConst;
import openfl.events.Event;
import engine.objects.Entity;
import engine.utils.Convert;

/**
 * ...
 * @author TommyX
 */
class Screen extends Entity
{
	public var paused:Bool;
	public var activated:Bool;
	
	public var viewport(default, null):Dynamic;
	
	public var cameraPos:Vec2D;
	public var cameraDepth:Float;
	public var cameraRotation:Float;
	
	public var cameraZoom(default, set):Float;
	@:noCompletion private function set_cameraZoom(value:Float):Float 
	{
		return cameraZoom = Math.max(value, 1);
	}
	
	public function getParallax(screenPos:Vec2DConst, depth:Float = 1):Vec2DConst
	{
		var a = Math.cos(Convert.rad(cameraRotation));
		var b = Math.sin(Convert.rad(cameraRotation));
		var c = -Math.sin(Convert.rad(cameraRotation));
		var d = Math.cos(Convert.rad(cameraRotation));
		var e = (screenPos.x - NRFDisplay.centerWidth) / cameraZoom * (depth - cameraDepth);
		var f = (screenPos.y - NRFDisplay.centerHeight) / cameraZoom * (depth - cameraDepth);
		var det = 1 / (a * d - b * c);
		var tx = det * (d * e - b * f) + cameraPos.x;
        var ty = det * (a * f - c * e) + cameraPos.y;
		return new Vec2DConst(tx, ty);
	}
	
	public function new()
	{
		super(this);

		paused = false;
		activated = false;
		cameraPos = new Vec2D();
		cameraDepth = 0;
		cameraZoom = 1;
		cameraRotation = 0;
		
		initViewport();
		addChild(viewport);
	}
	
	private function initViewport():Void
	{
		viewport = new Viewport(this);
	}
	
	public function activate():Void
	{
		//uh maybe check activationState here?
		activated = true;
		onActivate();
	}
	
	public function deactivate():Void
	{
		activated = false;
		onDeactivate();
	}
	
	private function onActivate():Void
	{
		this.visible = true;
		this.paused = false;
	}
	
	private function onDeactivate():Void
	{
		this.visible = false;
		this.paused = true;
	}
	
	private override function onEnterFrame(event:Event):Void
	{
		backgroundUpdate();
		if (paused == false){
			update();
		}
	}
	
	public override function remove():Void
	{
		
	}
	
}