package objects.primitive;

import engine.objects.AtlasContainer;
import states.State;
import screens.MainScreen;

/**
 * ...
 * @author TommyX
 */
class UIContainer extends AtlasContainer
{
	
	public var state:State;

	public function new(state:State) 
	{
		super(MainScreen.current.layerUI, null);
		
		this.pos.copyXY(-9999,-9999);
		
		this.state = state;
	}
	
	public override function removed():Void
	{
		while (children.length > 0){
			children[0].remove();
		}
	}
	
	public override function update():Void
	{
		if (visible && state.activated) {
			customUpdate();
		}
	}
	
	public function customUpdate():Void
	{
		
	}
	
}