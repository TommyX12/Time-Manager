package objects.primitive;

import engine.display.AtlasDisplay;
import screens.MainScreen;
import states.State;

/**
 * ...
 * @author TommyX
 */
class UITile extends UIEntity
{

	public function new(state:State, tile:String) 
	{
		super(state, tile);
		
		buttonEnabled = false;
	}
	
}