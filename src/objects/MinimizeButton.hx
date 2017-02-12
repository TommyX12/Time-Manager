package objects;

import objects.primitive.UIButton;
import states.State;

/**
 * ...
 * @author TommyX
 */
class MinimizeButton extends UIButton
{

	public function new(state:State) 
	{
		super(state, "_minus");
		
		this.width = this.height = 64;
	}
	
}