package;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.events.Event;

/**
 * ...
 * @author TommyX
 */

class Main extends Sprite 
{
	
	public var game:Game;
	
	public function new() 
	{
		super();
		
		game = new Game(1024, 1024);
		addChild(game);
	}
	
}