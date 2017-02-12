package engine.audio;

import openfl.display.Sprite;
import openfl.Assets;
import engine.audio.MusicChannel;
import openfl.events.Event;
import openfl.media.Sound;

/**
 * ...
 * @author TommyX
 */
class Musics extends Sprite
{
	
	public static var volume:Float = 1;
	
	private static var musicLibrary:Map<String,MusicChannel> = new Map<String,MusicChannel>();

	public function new() 
	{
		super();
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	public static function get(name:String):MusicChannel
	{
		return musicLibrary.get(name);
	}
	
	public static function setVolume(name:String, volume:Float):Void
	{
		get(name).volume = volume;
	}
	
	public static function newMusic(name:String, music:Sound):MusicChannel
	{
		var channel:MusicChannel = new MusicChannel(music);
		musicLibrary.set(name, channel);
		return channel;
	}
	
	public static function stopAll(fade:Float = 0.0):Void
	{
		for (music in musicLibrary) {
			music.stop(fade);
		}
	}
	
	public static function play(name:String, fade:Float=0.0, _stopAll:Bool=true, start:Float=-1.0, volume:Float=1.0, loop:Int = 99999999):Void
	{
		if (_stopAll) stopAll(fade);
		get(name).play(fade, start, volume, loop);
	}
	
	public static function pause(name:String, fade:Float=0.0):Void
	{
		get(name).pause(fade);
	}
	
	public static function stop(name:String, fade:Float=0.0):Void
	{
		get(name).stop(fade);
	}
	
	private function onEnterFrame(event:Event):Void
	{
		for (music in musicLibrary) {
			if (music.isPlaying) music.update();
		}
	}
	
}