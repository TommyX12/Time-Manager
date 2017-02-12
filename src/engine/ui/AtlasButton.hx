package engine.ui;

import engine.utils.*;
import openfl.geom.Rectangle;
import engine.display.AtlasTransformMode;
import engine.objects.AtlasEntity;
import engine.display.AtlasDisplay;

/**
 * ...
 * @author TommyX
 */
class AtlasButton extends AtlasEntity
{

    //support for rotation & complete transformation & offset
    //use globalTransform to determine hitbox

    public var identifier:String;

    public var pressed:Bool;
    public var released:Bool;
    public var down:Bool;
    public var hover:Bool;
	
	public var buttonEnabled:Bool;
    
    public var bound:Rectangle;
	
	public function new(layer:AtlasDisplay, tile:String)
	{
		super(layer, tile);
		
		buttonEnabled = true;
        
        this.transformMode = AtlasTransformMode.GLOBAL;
        
        identifier = "";
        
        pressed = false;
        released = false;
        down = false;
        hover = false;
        
        bound = new Rectangle(0,0,0,0);
	}
    
    public override function update():Void
    {
        if (buttonEnabled) {
			buttonUpdate();
			if (down) this.luminance = 0.4;
			else {
				if (hover) this.luminance = 1.2;
				else this.luminance = 0.8;
			}
		}
		else {
			this.down = false;
			this.pressed = false;
			this.released = false;
			this.hover = false;
			this.luminance = 0.8;
		}
    }
    
    public function buttonUpdate():Void
    {
        bound.width = this.width;
        bound.height = this.height;
        pressed = false;
        released = false;
        if (this.visible && bound.contains(Input.mousePos.x - this.pos.x -this.parent.pos.x + bound.width/2, Input.mousePos.y - this.pos.y -this.parent.pos.y + bound.height/2)){
            if (!hover) {
				hover = true;
				onHover();
			}
            if (Input.mousePressed){
                down = true;
                pressed = true;
				onPressed();
            }
        }
        else hover = false;
		if (Input.mouseReleased) {
			if (down) {
				if (hover){
					released = true;
					onReleased();
				}
				down = false;
			}
		}
    }
	
	public function onHover():Void
	{
		
	}
	
	public function onPressed():Void
	{
		
	}
	
	public function onReleased():Void
	{
		
	}
	
}