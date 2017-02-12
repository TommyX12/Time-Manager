package objects;

import objects.primitive.UIButton;
import states.State;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import screens.MainScreen;
import engine.display.AtlasTransformMode;

/**
 * ...
 * @author TommyX
 */
class BoxButton extends UIButton
{

	public function new(state:State, text:String) 
	{
		super(state, "_block");
		
		this.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
		this.text.width = 1000;
		this.text.text = text;
		setTextWidth(this.text.textWidth + 10);
		setTextHeight(this.text.textHeight + 10);
		this.width = this.text.width+40;
		this.height = this.text.height+10;
	}
	
}