package objects;

import engine.display.AtlasDisplay;
import engine.objects.AtlasContainer;
import engine.objects.AtlasEntity;
import engine.display.AtlasTransformMode;
import engine.utils.Grid;
import objects.info.Schedule;
import objects.primitive.UIContainer;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import objects.primitive.UIText;
import objects.primitive.UITextbox;
import screens.MainScreen;
import states.FullState;
import states.State;
import engine.utils.*;

/**
 * ...
 * @author TommyX
 */
class TimeLine extends UIContainer
{
	
	public static var length:Float = 1024;
	public var line:AtlasEntity;
	public var bg:AtlasEntity;
	public var pointer:AtlasEntity;
	
	public var overlayPtr:Int;
	
	public var hourTags:Array<UIText>;
	
	public var markers:Array<TaskMarker>;

	public function new(state:State) 
	{
		super(state);
		
		overlayPtr = 0;
		
		bg = new AtlasEntity(layer, "_gradient");
		bg.transformMode = AtlasTransformMode.LOCAL;
		bg.width = 450;
		bg.height = length;
		bg.pos.x = bg.width / 2;
		bg.pos.y = bg.height / 2;
		bg.alpha = 0.25;
		addChild(bg);
		
		line = new AtlasEntity(layer, "_line");
		line.transformMode = AtlasTransformMode.LOCAL;
		line.rotation = 90;
		line.width = length;
		line.pos.y = line.width / 2;
		addChild(line);
		
		hourTags = new Array<UIText>();
		for (h in 0...25) {
			var hourTag:UIText = new UIText(state);
			hourTag.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 20, 0x000000, null, null, null, null, null, TextFormatAlign.RIGHT);
			hourTag.transformMode = AtlasTransformMode.LOCAL;
			hourTag.pos.copyXY(0, h*length/24);
			hourTag.text.width = 88;
			hourTag.textPos.copyXY( -88, -16);
			hourTag.text.height = 32;
			hourTag.text.textColor = 0x444444;
			var i:Int = h == 24 ? 0 : h;
			hourTag.text.text = Convert.string(Util.getFileNameNumber(i, 2)) + " -";
			addChild(hourTag);
			hourTags.push(hourTag);
		}
		
		pointer = new AtlasEntity(layer, "_pointer");
		pointer.transformMode = AtlasTransformMode.LOCAL;
		pointer.width = 550;
		pointer.pos.x = 200;
		pointer.alpha = 0.7;
		addChild(pointer);
		
		markers = new Array<TaskMarker>();
	}
	
	public function refreshMarkers(date:Date) {
		for (marker in markers) {
			marker.remove();
		}
		markers = [];
		var time:Float = date.getTime();
		for (task in MainScreen.data_tasks) {
			for (schedule in task.schedules) {
				if (scheduleTest(schedule, time)) {
					var marker:TaskMarker = new TaskMarker(state);
					marker.transformMode = AtlasTransformMode.LOCAL;
					marker.setTask(task);
					marker.setSchedule(schedule);
					markers.push(marker);
					addChild(marker);
				}
			}
		}
		addChild(pointer);
	}
	
	public static function scheduleTest(schedule:Schedule, time:Float):Bool
	{
		for (cancel in schedule.canceled) {
			if (time == cancel) return false;
		}
		var startTime:Float = schedule.start.getTime();
		if (schedule.numOfTimes == 1) return startTime == time;
		if (time >= startTime) {
			var tempDate:Date = Date.fromTime(time);
			if (schedule.end != null) {
				if (tempDate.getFullYear() > schedule.end.getFullYear()) return false;
				else if (tempDate.getFullYear() == schedule.end.getFullYear()) {
					if (tempDate.getMonth() > schedule.end.getMonth()) return false;
					else if (tempDate.getMonth() == schedule.end.getMonth()) {
						if (tempDate.getDate() > schedule.end.getDate()) return false;
					}
				}
			}
			if (schedule.repeatUnit == "day" || schedule.repeatUnit == "week") {
				var _startTime:Float = (startTime - 18000000) / 86400000;
				if (_startTime != Convert.int(_startTime)) _startTime = Math.fround(_startTime);
				var _time:Float = (time - 18000000) / 86400000;
				if (_time != Convert.int(_time)) _time = Math.fround(_time);
				var repeat:Int = schedule.repeatPeriod;
				if (schedule.repeatUnit == "week") repeat *= 7;
				var test:Float = Math.abs(_time - _startTime) / repeat;
				return test == Convert.int(test);
			}
			if (schedule.repeatUnit == "month") {
				var _startTime:Float = schedule.start.getFullYear() * 12 + schedule.start.getMonth();
				var _time:Float = tempDate.getFullYear() * 12 + tempDate.getMonth();
				var repeat:Int = schedule.repeatPeriod;
				var test:Float = Convert.int(Math.abs(_time - _startTime)) / repeat;
				return test == Convert.int(test) && schedule.start.getDate() == tempDate.getDate();
			}
			if (schedule.repeatUnit == "year") {
				var _startTime:Float = schedule.start.getFullYear();
				var _time:Float = tempDate.getFullYear();
				var repeat:Int = schedule.repeatPeriod;
				var test:Float = Convert.int(Math.abs(_time - _startTime)) / repeat;
				return test == Convert.int(test) && schedule.start.getMonth() == tempDate.getMonth() && schedule.start.getDate() == tempDate.getDate();
			}
		}
		return false;
	}
	
	public override function customUpdate():Void
	{
		bg.color = MainScreen.current.scheme2Color;
		line.color = MainScreen.current.scheme1Color;
		if (FullState.current.syncToday){
			pointer.color = MainScreen.current.scheme1Color;
			pointer.r *= 0.5; pointer.g *= 0.5; pointer.b *= 0.5;
			pointer.pos.y = MainScreen.current.time_daysecond / 86400 * length;
			pointer.visible = true;
		}
		else pointer.visible = false;
		
		if (FullState.current.focusLevel == -1) {
			var overlay:Array<TaskMarker> = [];
			for (marker in markers) {
				if (marker.released) overlay.push(marker);
			}
			if (overlay[0] != null){
				if (FullState.current.mainMenu != null) FullState.current.mainMenu.remove();
				if (overlayPtr >= overlay.length) overlayPtr = 0;
				FullState.current.showTaskMenu(overlay[overlayPtr]);
				overlayPtr++;
			}
		}
		
		//only able to trigger marker if focuslv is -1
	}
	
}