package states;

import screens.MainScreen;
import engine.objects.AtlasContainer;

/**
 * ...
 * @author TommyX
 */
class State extends AtlasContainer
{
	
	public var activated:Bool;

	public function new() 
	{
		super(MainScreen.current.layerUI);

		activated = false;
		visible = false;
	}
	
	public function hide():Void
	{
		activated = false;
		visible = false;
	}
	
	public function show():Void
	{
		activated = true;
		visible = true;
	}
	
}