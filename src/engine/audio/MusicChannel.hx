package engine.audio;
import engine.utils.Convert;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

/**
 * ...
 * @author TommyX
 */
class MusicChannel
{
	
	public var audio(default, null):Sound;
	public var audioChannel(default, null):SoundChannel;
	private var audioTransform:SoundTransform;
	public var volume:Float;
	private var fade:Float;
	private var fadeSpeed:Float;
	public var isPlaying(default, null):Bool;
	public var isPaused(default, null):Bool;
	public var pausePos(default, null):Float;

	public function new(audio:Sound) 
	{
		this.audio = audio;
		audioTransform = new SoundTransform();
		volume = 1;
		fade = 0;
		fadeSpeed = 0;
		isPlaying = false;
		isPaused = false;
		pausePos = 0;
	}
	
	public function play(_fade:Float=0.0, start:Float=-1.0, volume:Float=1.0, loop:Int = 99999999):Void
	{
		if (isPlaying){
			if (start >= 0.0) {
				_stop();
				audioTransform.volume = fade = 0;
				audioChannel = audio.play(start * 1000, loop, audioTransform);
			}
			setFade(true, _fade);
			isPaused = false;
		}
		else {
			if (start < 0.0) {
				if (isPaused) start = pausePos;
				else start = 0.0;
			}
			audioTransform.volume = fade = 0;
			audioChannel = audio.play(start * 1000, loop, audioTransform);
			//audioChannel.pitch = 1.2;
			setFade(true, _fade);
			audioChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		isPlaying = true;
		isPaused = false;
	}
	
	public function pause(fade:Float=0.0):Void
	{
		if (isPlaying && isPaused == false) {
			setFade(false, fade);
			isPaused = true;
		}
	}
	
	public function stop(fade:Float=0.0):Void
	{
		setFade(false, fade);
	}
	
	private function _stop():Void
	{
		if (isPlaying) {
			if (isPaused) pausePos = audioChannel.position/1000;
			audioChannel.stop();
			isPlaying = false;
		}
	}
	
	private function setFade(fadeIn:Bool, duration:Float):Void
	{
		var rate:Float = duration == 0 ? 1 : 1 / Convert.frame(duration);
		rate *= fadeIn ? 1 : -1;
		fadeSpeed = rate;
	}
	
	private function onSoundComplete(event:Event):Void
	{
		isPlaying = false;
	}
	
	public function update():Void
	{
		fade = Math.min(Math.max(fade + fadeSpeed, 0), 1);
		if (fadeSpeed < 0 && fade <= 0) _stop();
		audioTransform.volume = volume * fade * Musics.volume;
		if (isPlaying) audioChannel.soundTransform = audioTransform;
	}
	
}