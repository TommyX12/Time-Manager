package engine;

import engine.utils.Convert;
import engine.utils.Vec2D;
import openfl.geom.Point;
import openfl.Lib;
import openfl.display.StageDisplayState;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.display.StageQuality;
import openfl.events.Event;
import openfl.system.Capabilities;

/**
 * ...
 * @author TommyX
 */
class NRFDisplay
{

	public static var rawWidth(default, null):Int = 0;
	public static var rawHeight(default, null):Int = 0;
	public static var centerWidth(default, null):Float = 0;
	public static var centerHeight(default, null):Float = 0;
	public static var centerPos(default, null):Vec2D;
	public static var currentWidth(default, null):Float = 0;
	public static var currentHeight(default, null):Float = 0;
	public static var scaleFactor(default, null):Float = 1;
	public static var stageShiftX(default, null):Float = 0;
	public static var stageShiftY(default, null):Float = 0;
	public static var localStageShiftX(default, null):Float = 0;
	public static var localStageShiftY(default, null):Float = 0;
	public static var fullScreen:Bool = false;
	public static var resolutionX:Int = 0;
	public static var resolutionY:Int = 0;
	
	public static var resolutionOptions(default, null):Array<Array<Int>> = 
		[
		
		]
	;
	
	public static var fps:Float = 0;
	public static var displayFPS:Bool = false;//doesnt work on hybrid
	
	public static var bitmapSmoothing:Bool = true;
	public static var atlasSmoothing:Bool = true; //setting true might produce white border artifact
	
	public static var textureQuality:String = "high";
	public static var textureScale:Float = 1;
	
	public static var fxaa:Bool = false;
	
	public static var hdr:Bool = false;
	
	public static var godRays:Bool = false;
	public static var godRaysIntensity:Float = 1.0;
	
	public static var fxMap:Bool = false;
	
	public static var motionBlur:Bool = false;
	public static var motionBlurRes:Float = 0.5;
	public static var motionBlurIntensity:Float = 0.0075;
	
	public static var vignetteRadius:Float = 500;
	public static var vignetteFade:Float = 450;
	public static var noiseIntensity:Float = 0.035;
	public static var scanlineIntensity:Float = 0.015;
	public static var chromaticAberrationSize:Float = 0.0035;
	public static var chromaticAberrationIntensity:Float = 0.75;
	public static var chromaticAberrationZoomMultiplier:Float = 0.35;
	
	public static function initialize(_rawWidth:Int, _rawHeight:Int):Void
	{
		rawWidth = _rawWidth;
		rawHeight = _rawHeight;
		centerWidth = rawWidth / 2;
		centerHeight = rawHeight / 2;
		centerPos = new Vec2D(centerWidth, centerHeight);
		
		switch (textureQuality) 
		{
			case "low":
				textureScale = 0.25;
			case "mid":
				textureScale = 0.5;
			case "high":
				textureScale = 1;
		}
		
		fullScreen = false;
		resolutionX = Convert.int(Capabilities.screenResolutionX);
		resolutionY = Convert.int(Capabilities.screenResolutionY);
		
		//applySettings();//only works on lime 2.1.2
		
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
		onResize(null);
		
		fps = Lib.current.stage.frameRate;
		
		//trace(GL.getParameter(GL.MAX_TEXTURE_SIZE));
	
		//Lib.current.stage.quality = StageQuality.LOW;
	}
	
	private static function onResize(event:Event):Void 
	{
		currentWidth = Lib.current.stage.stageWidth;
		currentHeight = Lib.current.stage.stageHeight;
		if (currentWidth / currentHeight > NRFDisplay.rawWidth / NRFDisplay.rawHeight) {
			scaleFactor = currentHeight / NRFDisplay.rawHeight;
			NRFGame.current.scaleX = NRFGame.current.scaleY = scaleFactor;
			currentWidth /= scaleFactor;
			currentHeight = rawHeight;
			/*
			NRFGame.current.x = (currentWidth - NRFDisplay.rawWidth * scaleFactor) / 2;
			stageShiftX = NRFGame.current.x;
			localStageShiftX = stageShiftX / scaleFactor;
			NRFGame.current.y = 0;
			stageShiftY = 0;
			localStageShiftY = 0;
			*/
		}
		else {
			scaleFactor = currentWidth / NRFDisplay.rawWidth;
			NRFGame.current.scaleX = NRFGame.current.scaleY = scaleFactor;
			currentWidth = rawWidth;
			currentHeight /= scaleFactor;
			/*
			NRFGame.current.x = 0;
			stageShiftX = 0;
			localStageShiftX = 0;
			NRFGame.current.y = (currentHeight - NRFDisplay.rawHeight * scaleFactor) / 2;
			stageShiftY = NRFGame.current.y;
			localStageShiftY = stageShiftY / scaleFactor;
			*/
		}
		centerWidth = currentWidth / 2;
		centerHeight = currentHeight / 2;
		centerPos.copyXY(centerWidth, centerHeight);
	}
	
	public static function applySettings():Void
	{
		if (fullScreen) {
			if (Lib.current.stage.displayState == StageDisplayState.NORMAL){
				Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			if (Capabilities.screenResolutionX != resolutionX || Capabilities.screenResolutionY != resolutionY){
				Lib.current.stage.setResolution(resolutionX, resolutionY);
			}
		}
		else {
			if (Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE){
				Lib.current.stage.displayState = StageDisplayState.NORMAL;
			}
			Lib.current.stage.resize(resolutionX, resolutionY);
		}
		
	}
	
}