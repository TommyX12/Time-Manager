package;

import engine.assets.TextureAtlas;
import engine.NRFGame;
import openfl.Assets;
import engine.assets.Textures;
import engine.audio.Musics;
import openfl.media.Sound;
import openfl.utils.ByteArray;
import engine.assets.AssetsManager;
import screens.MainScreen;

/**
 * ...
 * @author TommyX
 */
class Game extends NRFGame
{

	public var mainScreen:MainScreen;
	
	public function new(rawWidth:Int, rawHeight:Int) 
	{
		super(rawWidth, rawHeight);
		
		fps.textColor = 0x000000;
		
		mainScreen = new MainScreen();
	}
	
	public override function added():Void
	{
		addScreen(mainScreen);
		mainScreen.activate();
	}
	
	public override function initializeAssets():Void
	{
		// Textures
		Textures.newSparrowAtlas("UIAtlas", "textures/uiAtlas", false);
		// ----
	}
	
}