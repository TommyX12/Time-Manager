package objects.primitive;

import engine.display.AtlasDisplay;
import screens.MainScreen;
import states.State;

/**
 * ...
 * @author TommyX
 */
class UITitle extends UIEntity
{

	public function new(state:State) 
	{
		super(state, "_null");
		
		buttonEnabled = false;
		text.defaultTextFormat = MainScreen.TEXT_FORMAT_TITLE;
	}
	
}