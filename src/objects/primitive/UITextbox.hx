package objects.primitive;

import engine.display.AtlasDisplay;
import screens.MainScreen;
import openfl.text.TextFieldType;
import states.State;

/**
 * ...
 * @author TommyX
 */
class UITextbox extends UIEntity
{

	public function new(state:State, tile:String) 
	{
		super(state, tile);
		
		buttonEnabled = false;
		text.type = TextFieldType.INPUT;
		text.selectable = true;
		text.border = true;
		text.borderColor = 0x000000;
		text.defaultTextFormat = MainScreen.TEXT_FORMAT_INPUT;
	}
	
}