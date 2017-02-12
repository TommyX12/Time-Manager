package objects;

import engine.display.AtlasDisplay;
import engine.display.AtlasTransformMode;
import objects.primitive.UIButton;
import screens.MainScreen;
import engine.NRFDisplay;
import states.State;

/**
 * ...
 * @author TommyX
 */
class StartBtn extends UIButton
{

	public function new(state:State)
	{
		super(state, "_add");
		
		this.width = this.height = 600;
	}
	
}