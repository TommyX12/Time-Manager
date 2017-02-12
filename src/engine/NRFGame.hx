package engine;

import engine.assets.AssetsManager;
import engine.assets.Textures;
import engine.audio.Musics;
import engine.display.Screen;
import engine.utils.Input;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.FPS;
import openfl.system.System;
import openfl.net.SharedObject;

/**
 * ...
 * @author TommyX
 */
class NRFGame extends Sprite
{
	
	public static var current(default, null):NRFGame;
	
	public static var saveFile:SharedObject=SharedObject.getLocal("NRF/save","/");
	
	private var fpsAdded:Bool;
	private var fps:FPS;
	
	public var screens(default, null):Array<Screen>;
	
	public var musics(default, null):Musics;
	public var input(default, null):Input;
	
	public function new(rawWidth:Int, rawHeight:Int) 
	{
		super();
		
		current = this;
		NRFDisplay.initialize(rawWidth, rawHeight);
		
		AssetsManager.initialize();
		initializeAssets();
		
		screens = new Array<Screen>();
		
		fps = new FPS(10, 10, 0xffffff);
		fpsAdded = false;
		
		musics = new Musics();
		input = new Input();

		if (saveFile.data.initialized == null) {
			saveFile.setProperty("initialized", true);
		}
		
		saveFile.flush(1048576);
		//Do not attempt to save Classes
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	public function onAddedToStage(event:Event):Void
	{
		addChild(musics);
		addChild(input);
		
		added();
		
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	public function onEnterFrame(event:Event):Void
	{
		if (fpsAdded == false) {
			fpsAdded = true;
			if (NRFDisplay.displayFPS){
				this.parent.addChild(fps);
			}
		}
		update();
		//System.exit();
	}
	
	public function added():Void
	{
		
	}
	
	public function update():Void 
	{
		
	}
	
	public function addScreen(screen:Screen):Void
	{
		screens.push(screen);
		addChild(screen);
	}
	
	public function deactivateAll():Void
	{
		for (screen in screens) {
			screen.deactivate();
		}
	}
	
	public function initializeAssets():Void
	{
		// override
	}
	
}