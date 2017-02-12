package engine.objects;

import engine.display.AtlasDisplay;
import engine.objects.AtlasEntity;


class AtlasAnimEntity extends AtlasEntity
{
	public var onComplete:Dynamic;

	public var frames:Array<Int>;
	public var fps(default, set):Float;
	public var loop:Bool;
	public var totalFrames:Int;
	public var currentFrame:Int;
	public var speed(default, null):Float;
	private var time:Float;
	
	function set_fps(value:Float):Float
	{
		speed = NRFDisplay.fps / value;
		return fps = value;
	}

	public function new(layer:AtlasDisplay, tile:String, fps:Float, loop:Bool=true)
	{
		super(layer, tile);
		stringID = "AtlasEntity";
		this.fps = fps;
		time = -1;
		currentFrame = 0;
		animated = true;
		this.loop = loop;
	}

	override function init(layer:AtlasDisplay):Void
	{
		this.layer = layer;
		frames = layer.tilesheet.getAnim(tile);
		totalFrames = frames.length;
		indice = frames[0];
		size = layer.tilesheet.getSize(indice);
	}

	override function step()
	{
		time++;
		while (time >= speed) {
			time -= speed;
			if (currentFrame == totalFrames - 1) {
				if (loop) currentFrame = 0;
				else {
					stop();
					onComplete();
					break;
				}
			}
			else currentFrame++;
		}
		indice = frames[currentFrame];
	}

	public function play() { 
		animated = true; 
		if (currentFrame == totalFrames - 1) {
			currentFrame = 0;
			time = -1;
		}
	}
	public function stop() { animated = false; }
}
