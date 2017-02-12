package objects;

import objects.primitive.UIText;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import states.State;
import screens.MainScreen;
import engine.utils.*;

/**
 * ...
 * @author TommyX
 */
class Clock extends UIText
{
	
	var cachedSec:Float;

	public function new(state:State) 
	{
		super(state);
		
		text.width = 800;
		text.height = 400;
		textPos.x = -800;
		text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0x000000, null, null, null, null, null, TextFormatAlign.RIGHT);
		
	}
	
	public override function colorUpdate():Void
	{
		
	}
	
	public static function getWeekdayText(weekday:Int):String
	{
		switch (weekday) 
		{
			case 1:
				return "Monday";
			case 2:
				return "Tuesday";
			case 3:
				return "Wednesday";
			case 4:
				return "Thursday";
			case 5:
				return "Friday";
			case 6:
				return "Saturday";
			case 7:
				return "Sunday";
		}
		return null;
	}
	
	public override function customUpdate():Void
	{
		if (MainScreen.current.time_second != cachedSec) {
			text.textColor = MainScreen.current.scheme1Color;
			text.text = 
			Util.getFileNameNumber(MainScreen.current.time_hour, 2)
			+ ":"
			+ Util.getFileNameNumber(MainScreen.current.time_minute, 2)
			+ ":"
			+ Util.getFileNameNumber(MainScreen.current.time_second, 2)
			+ " - "
			+ MainScreen.current.time_weekday + "(" + getWeekdayText(MainScreen.current.time_weekday).substr(0, 3) + ")" + " "
			+ Util.getFileNameNumber(MainScreen.current.time_year, 4)
			+ "-"
			+ Util.getFileNameNumber(MainScreen.current.time_month, 2)
			+ "-"
			+ Util.getFileNameNumber(MainScreen.current.time_day, 2);
			cachedSec = MainScreen.current.time_second;
		}
		
	}
}