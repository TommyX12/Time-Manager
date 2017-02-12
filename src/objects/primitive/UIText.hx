package objects.primitive;

import states.State;

/**
 * ...
 * @author TommyX
 */
class UIText extends UIEntity
{

	public function new(state:State) 
	{
		super(state, "_null");
		
		buttonEnabled = false;
	}
	
}