package objects.primitive;

import engine.display.AtlasDisplay;
import engine.ui.AtlasButton;
import engine.utils.Vec2D;
import openfl.text.TextField;
import screens.MainScreen;
import openfl.text.TextFieldAutoSize;
import openfl.text.AntiAliasType;
import openfl.text.TextFieldType;
import states.State;

/**
 * ...
 * @author TommyX
 */
class UIEntity extends AtlasButton
{
	
	public var text:TextField;
	public var textPos:Vec2D;
	
	public var state:State;
	
	public var colorTheme:Int;
	
	public var visibleDelay:Int;

	public function new(state:State, tile:String) 
	{
		super(MainScreen.current.layerUI, tile);
		
		colorTheme = 1;
		
		this.state = state;
		
		this.pos.copyXY(-9999,-9999);
		
		visibleDelay = 1;
		
		text = new TextField();
		text.embedFonts = true;
		text.defaultTextFormat = MainScreen.TEXT_FORMAT_DEFAULT;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.type = TextFieldType.DYNAMIC;
		text.selectable = false;
		text.multiline = true;
		text.visible = false;
		text.wordWrap = true;
		textPos = new Vec2D();
	}
	
	public function setTextWidth(width:Float):Void
	{
		textPos.x = -width / 2;
		text.width = width;
	}
	
	public function setTextHeight(height:Float):Void
	{
		textPos.y = -height / 2;
		text.height = height;
	}
	
	public override function added():Void
	{
		MainScreen.current.layerText.addChild(text);
	}
	
	public override function removed():Void
	{
		MainScreen.current.layerText.removeChild(text);
		text = null;
	}
	
	public function colorUpdate():Void
	{
		if (colorTheme == 1) this.color = MainScreen.current.scheme1Color;
		else if (colorTheme == 2) this.color = MainScreen.current.scheme2Color;
	}
	
	public override function update():Void
	{
		if (buttonEnabled && state.activated && visible && parent.visible) buttonUpdate();
		else {
			this.down = false;
			this.pressed = false;
			this.released = false;
			this.hover = false;
		}
		if (visibleDelay <= 0) text.visible = state.visible && this.parent.visible && this.visible;
		else visibleDelay--;
		if (state.activated){
			colorUpdate();
			text.x = this.globalTransform.tx + textPos.x;
			text.y = this.globalTransform.ty + textPos.y;
			if (down) {
				this.luminance = 0.8;
			}
			else {
				if (hover) {
					this.luminance = 1.2;
				}
				else {
					this.luminance = 1;
				}
			}
			customUpdate();
		}
	}
	
	public function customUpdate():Void
	{
		
	}
	
}