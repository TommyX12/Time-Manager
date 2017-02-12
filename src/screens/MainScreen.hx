package screens;

import engine.display.AtlasDisplay;
import engine.display.Screen;
import engine.objects.Entity;
import engine.ui.AtlasButton;
import objects.info.Project;
import objects.info.Schedule;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import engine.utils.*;
import engine.assets.Textures;
import engine.display.AtlasTransformMode;
import engine.NRFDisplay;
import objects.primitive.UIEntity;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.Assets;
import openfl.text.Font;
import openfl.utils.ByteArray;
import states.FullState;
import states.MiniState;
import objects.info.Task;
import objects.info.TaskType;
import engine.assets.AssetsManager;
import sys.*;
import openfl.Lib;
import sys.io.*;

@:font("assets/Fonts/font.ttf") class DefaultFont extends Font { }

/**
 * ...
 * @author TommyX
 */
class MainScreen extends Screen
{
	
	//scheme color changes everytime it launches, and every hour.
	
	//flashing taskbar. c++
	
	var a:URLLoader;
	
	public static var TEXT_FORMAT_DEFAULT:TextFormat;
	public static var TEXT_FORMAT_TITLE:TextFormat;
	public static var TEXT_FORMAT_SUBTITLE:TextFormat;
	public static var TEXT_FORMAT_INPUT:TextFormat;
	public static var TEXT_FONT_NAME:String;
	
	public static var TASK_NAME_MAXCHARS:Int = 32;
	public static var TASK_NOTE_MAXCHARS:Int = 1024;
	
	public static var dataPath:String;
	public static var tasksPath:String;
	
	public static var data_tasktypes_name:Array<String> = [];
	public static var data_tasktypes_color:Array<Int> = [];
	public static var data_tasks:Array<Task> = [];
	
	public static var alert:Dynamic;
	
	public var scheme1R:Float;
	public var scheme1G:Float;
	public var scheme1B:Float;
	public var scheme1Color:Int;
	
	public var scheme2R:Float;
	public var scheme2G:Float;
	public var scheme2B:Float;
	public var scheme2Color:Int;
	
	public var rest:Bool;
	
	public var layerUI:AtlasDisplay;
	public var layerText:Entity;
	
	public var state_mini:MiniState;
	public var state_full:FullState;
	
	public var time_year:Int;
	public var time_month:Int;
	public var time_day:Int;
	public var time_weekday:Int;
	public var time_hour:Int;
	public var time_minute:Int;
	public var time_second:Int;
	public var time_daysecond:Int;
	
	public static var current:MainScreen;
	public static var hasConflict:Bool=false;
	
	public var taskList:Array<Task>;

	public function new() 
	{
		super();
		
		viewport.mouseChildren = true;
		viewport.mouseEnabled = true;
		
		alert = Lib.load ("lime", "lime_window_alert", 2);//message, title
		
		rest = false;
		
		time_day = -1;
		time_minute = -1;
		
		Font.registerFont(DefaultFont);
		TEXT_FONT_NAME = new DefaultFont().fontName;
		TEXT_FORMAT_DEFAULT = new TextFormat(TEXT_FONT_NAME, 32, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.LEFT);
		TEXT_FORMAT_TITLE = new TextFormat(TEXT_FONT_NAME, 64, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
		TEXT_FORMAT_SUBTITLE = new TextFormat(TEXT_FONT_NAME, 40, 0x000000, null, null, null, null, null, TextFormatAlign.LEFT);
		TEXT_FORMAT_INPUT = new TextFormat(TEXT_FONT_NAME, 32, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.LEFT);
		
		layerUI = new AtlasDisplay(viewport.main, Textures.getAtlas("UIAtlas"));
		layerText = new Entity(this);
		this.viewport.addChild(layerText);
		
		loadData();
		
		a = new URLLoader();
		a.dataFormat = URLLoaderDataFormat.TEXT;
		//a.load(new URLRequest("http://www.google.ca/"));
	}
	
	public static function loadData():Void
	{
		dataPath = AssetsManager.execPath + AssetsManager.outPath + "profile\\";
		tasksPath = dataPath + "tasks\\";
		if (!FileSystem.exists(dataPath)) FileSystem.createDirectory(dataPath);
		if (!FileSystem.exists(tasksPath)) FileSystem.createDirectory(tasksPath);
		
		var inHandle:FileInput;
		var inByteArray:ByteArray;
		var inString:String;
		var p:Int;
		var pp:Int;
		var l:Int;
		
		if (!FileSystem.exists(dataPath + "tasktypes.info")) {
			var outHandle:FileOutput = File.write(dataPath + "tasktypes.info", true);
			outHandle.close();
		}
		inHandle = File.read(dataPath + "tasktypes.info");
		inByteArray = new ByteArray();
		inByteArray.writeBytes(inHandle.readAll());
		inString = inByteArray.toString();
		p = 0;
		while (true) {
			p = inString.indexOf("[name]", p);
			if (p == -1) break;
			p = inString.indexOf("]", p) + 2;
			pp = inString.indexOf("\n", p);
			data_tasktypes_name.push(inString.substring(p, pp));
			p = inString.indexOf("[color]", pp);
			p = inString.indexOf("R:", p) + 2;
			pp = inString.indexOf(" ", p);
			var r:Int = Convert.int(inString.substring(p, pp));
			p = inString.indexOf("G:", pp) + 2;
			pp = inString.indexOf(" ", p);
			var g:Int = Convert.int(inString.substring(p, pp));
			p = inString.indexOf("B:", pp) + 2;
			pp = inString.indexOf(" ", p);
			var b:Int = Convert.int(inString.substring(p, pp));
			data_tasktypes_color.push(Convert.color(r, g, b));
		}
		
		var contents:Array<String> = FileSystem.readDirectory(tasksPath);
		for (content in contents) {
			inHandle = File.read(tasksPath + content, true);
			inByteArray = new ByteArray();
			inByteArray.writeBytes(inHandle.readAll());
			inString = inByteArray.toString();
			
			var task:Task;
			var isProject:Bool = false;
			p = inString.lastIndexOf("[goal type]");
			p = inString.indexOf("]", p) + 2;
			pp = inString.indexOf("\n", p);
			if (inString.substring(p, pp) == "project") {
				task = new Project();
				isProject = true;
			}
			else task = new Task();
			
			p = inString.indexOf("[name]", p);
			p = inString.indexOf("]", p) + 2;
			pp = inString.indexOf("\n", p);
			task.name = inString.substring(p, pp);
			p = inString.indexOf("[type]", pp);
			p = inString.indexOf("]", p) + 2;
			pp = inString.indexOf("\n", p);
			task.type = inString.substring(p, pp);
			p = inString.indexOf("[note]", pp);
			p = inString.indexOf("]", p) + 2;
			pp = inString.lastIndexOf("\n---End of Note---");
			task.note = inString.substring(p, pp);
			p = inString.indexOf("[goal type]", pp);
			p = inString.indexOf("]", p) + 2;
			pp = inString.indexOf("\n", p);
			task.goalType = inString.substring(p, pp);
			p = inString.indexOf("[goal]", pp);
			p = inString.indexOf("]", p) + 2;
			pp = inString.indexOf("\n", p);
			task.goal = Convert.int(inString.substring(p, pp));
			while (true) {
				p = inString.indexOf("[schedule]", pp);
				if (p == -1) break;
				var schedule:Schedule = new Schedule();
				p = inString.indexOf("[start date]", pp);
				p = inString.indexOf("]", p) + 2;
				pp = inString.indexOf("\n", p);
				schedule.start = Date.fromString(inString.substring(p, pp));
				p = inString.indexOf("[end date]", pp);
				if (p != -1){
					p = inString.indexOf("]", p) + 2;
					pp = inString.indexOf("\n", p);
					schedule.end = inString.substring(p, pp) == "null" ? null : Date.fromString(inString.substring(p, pp));
				}
				p = inString.indexOf("[start minute]", pp);
				p = inString.indexOf("]", p) + 2;
				pp = inString.indexOf("\n", p);
				schedule.startMinute = Convert.int(inString.substring(p, pp));
				p = inString.indexOf("[end minute]", pp);
				p = inString.indexOf("]", p) + 2;
				pp = inString.indexOf("\n", p);
				schedule.endMinute = Convert.int(inString.substring(p, pp));
				p = inString.indexOf("[repeat period]", pp);
				p = inString.indexOf("]", p) + 2;
				pp = inString.indexOf("\n", p);
				schedule.repeatPeriod = Convert.int(inString.substring(p, pp));
				p = inString.indexOf("[repeat unit]", pp);
				p = inString.indexOf("]", p) + 2;
				pp = inString.indexOf("\n", p);
				schedule.repeatUnit = inString.substring(p, pp);
				p = inString.indexOf("[repeat times]", pp);
				p = inString.indexOf("]", p) + 2;
				pp = inString.indexOf("\n", p);
				schedule.numOfTimes = Convert.int(inString.substring(p, pp));
				p = inString.indexOf("[is auto]", pp);
				if (p != -1){
					p = inString.indexOf("]", p) + 2;
					pp = inString.indexOf("\n", p);
					schedule.isAuto = inString.substring(p, pp) == "true";
				}
				p = inString.indexOf("[canceled]", pp);
				p = inString.indexOf("]", p) + 2;
				pp = inString.indexOf("---End of Schedule---", p)-1;
				var canceled:Array<String> = inString.substring(p, pp).split("\n");
				for (item in canceled) {
					if (item != "") schedule.canceled.push(Date.fromString(item).getTime());
				}
				task.schedules.push(schedule);
			}
			if (isProject) {
				var project:Project = cast task;
				p = inString.indexOf("[subtasks]");
				p = inString.indexOf("]", p) + 2;
				pp = inString.indexOf("---End of Subtasks---", p) - 1;
				var subtasks:Array<String> = inString.substring(p, pp).split("\n");
				if (subtasks[0] != "") {
					for (i in 0...Convert.int(subtasks.length / 2)) {
						var a:Int = Convert.int(subtasks[i * 2]);
						var b:String = subtasks[i * 2 + 1];
						project.subtasks.push(a);
						if (a == -1) {
							project.subtasks.push(Date.fromString(b));
						}
						else project.subtasks.push(b);
					}
				}
			}
			data_tasks.push(task);
		}
	}
	
	public static function saveData(backup:Bool=false):Void
	{
		//if (hasConflict) return;
		var purgeYear:Int = Date.now().getFullYear() - 2;
		
		var outHandle:FileOutput;
		var outString:String;
		
		outHandle = File.write(dataPath + "tasktypes.info", true);
		outString = "";
		for (i in 0...data_tasktypes_name.length) {
			outString += "[name]";
			outString += "\n";
			outString += data_tasktypes_name[i];
			outString += "\n";
			outString += "[color]";
			outString += "\n";
			outString += "R:";
			outString += (data_tasktypes_color[i] >> 16) & 0xFF;
			outString += " ";
			outString += "G:";
			outString += (data_tasktypes_color[i] >> 8) & 0xFF;
			outString += " ";
			outString += "B:";
			outString += data_tasktypes_color[i] & 0xFF;
			outString += " ";
			outString += "\n\n";
		}
		outHandle.writeString(outString);
		outHandle.close();
		
		for (task in data_tasks) {
			var ext:String = ".task";
			if (task.goalType == "project") ext = ".project"; 
			outHandle = File.write(tasksPath + task.name + ext, true);
			outString = "";
			outString += "[name]";
			outString += "\n";
			outString += task.name;
			outString += "\n\n";
			outString += "[type]";
			outString += "\n";
			outString += task.type;
			outString += "\n\n";
			outString += "[note]";
			outString += "\n";
			outString += task.note;
			outString += "\n---End of Note---\n\n";
			outString += "[goal type]";
			outString += "\n";
			outString += task.goalType;
			outString += "\n";
			outString += "[goal]";
			outString += "\n";
			outString += Convert.string(task.goal);
			outString += "\n\n";
			for (schedule in task.schedules) {
				var ctn:Bool = true;
				if (schedule.numOfTimes == 1) {
					if (schedule.start.getFullYear() < purgeYear) {
						ctn = false;
					}
				}
				else if (schedule.end != null && schedule.end.getFullYear() < purgeYear) {
					ctn = false;
				}
				if (ctn){
					outString += "[schedule]\n";
					outString += "[start date]";
					outString += "\n";
					outString += schedule.start.toString();
					outString += "\n";
					outString += "[end date]";
					outString += "\n";
					outString += schedule.end == null ? "null" : schedule.end.toString();
					outString += "\n";
					outString += "[start minute]";
					outString += "\n";
					outString += Convert.string(schedule.startMinute);
					outString += "\n";
					outString += "[end minute]";
					outString += "\n";
					outString += Convert.string(schedule.endMinute);
					outString += "\n";
					outString += "[repeat period]";
					outString += "\n";
					outString += Convert.string(schedule.repeatPeriod);
					outString += "\n";
					outString += "[repeat unit]";
					outString += "\n";
					outString += schedule.repeatUnit;
					outString += "\n";
					outString += "[repeat times]";
					outString += "\n";
					outString += Convert.string(schedule.numOfTimes);
					outString += "\n";
					outString += "[is auto]";
					outString += "\n";
					outString += Convert.string(schedule.isAuto);
					outString += "\n";
					outString += "[canceled]";
					for (cancel in schedule.canceled) {
						var ctnc:Bool = true;
						if (Date.fromTime(cancel).getFullYear() < purgeYear) ctnc = false;
						if (ctnc){
							outString += "\n";
							outString += Date.fromTime(cancel).toString();
						}
					}
					outString += "\n---End of Schedule---\n\n";
				}
			}
			if (task.goalType == "project") {
				var project:Project = cast task;
				outString += "[subtasks]";
				outString += "\n";
				for (i in 0...Convert.int(project.subtasks.length / 2)) {
					var a:Dynamic = project.subtasks[i * 2];
					var b:Dynamic = project.subtasks[i * 2 + 1];
					outString += Convert.string(a);
					outString += "\n";
					if (a == -1) {
						outString += b.toString();
						outString += "\n";
					}
					else {
						outString += b;
						outString += "\n";
					}
				}
				outString += "---End of Subtasks---";
				outString += "\n\n";
			}
			outHandle.writeString(outString);
			outHandle.close();
		}
	}
	
	public static function deleteTask(task:Task, fileOnly:Bool = false):Void
	{
		var ext:String = ".task";
		if (task.goalType == "project") ext = ".project"; 
		FileSystem.deleteFile(tasksPath + task.name + ext);
		if (!fileOnly){
			data_tasks.remove(task);
			FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
		}
	}
	
	public override function onActivate():Void
	{
		current = this;
		
		genSchemeColor();
		time_hour = Date.now().getHours();
		
		state_mini = new MiniState();
		layerUI.addChild(state_mini);
		state_full = new FullState();
		layerUI.addChild(state_full);
		
		state_mini.show();
		
		updateTime();
	}
	
	public function genSchemeColor():Void
	{
		var h:Float = Math.random();
		var l:Float = Util.random(0.65, 0.75);
		var s:Float = Util.random(0.3, 0.8);
		var t2:Float = (l<=0.5)? l*(1+s):l+s-(l*s);
		var t1:Float = 2*l-t2;
		var t3:Array<Float> = new Array<Float>();
		t3.push(h+1/3);
		t3.push(h);
		t3.push(h-1/3);
		var clr:Array<Float> = new Array<Float>();
		clr.push(0);
		clr.push(0);
		clr.push(0);
		for(i in 0...3)
		{
			if(t3[i]<0)
				t3[i]+=1;
			if(t3[i]>1)
				t3[i]-=1;

			if(6*t3[i] < 1)
				clr[i]=t1+(t2-t1)*t3[i]*6;
			else if(2*t3[i]<1)
				clr[i]=t2;
			else if(3*t3[i]<2)
				clr[i]=(t1+(t2-t1)*((2/3)-t3[i])*6);
			else
				clr[i]=t1;
		}
		scheme1R = clr[0];
		scheme1G = clr[1];
		scheme1B = clr[2];
		scheme1Color = Convert.colorFloat(scheme1R, scheme1G, scheme1B);
		
		h = Math.random();
		l = Util.random(0.65, 0.75);
		s = Util.random(0.3, 0.8);
		t2 = (l<=0.5)? l*(1+s):l+s-(l*s);
		t1 = 2*l-t2;
		t3 = new Array<Float>();
		t3.push(h+1/3);
		t3.push(h);
		t3.push(h-1/3);
		clr = new Array<Float>();
		clr.push(0);
		clr.push(0);
		clr.push(0);
		for(i in 0...3)
		{
			if(t3[i]<0)
				t3[i]+=1;
			if(t3[i]>1)
				t3[i]-=1;

			if(6*t3[i] < 1)
				clr[i]=t1+(t2-t1)*t3[i]*6;
			else if(2*t3[i]<1)
				clr[i]=t2;
			else if(3*t3[i]<2)
				clr[i]=(t1+(t2-t1)*((2/3)-t3[i])*6);
			else
				clr[i]=t1;
		}
		scheme2R = clr[0];
		scheme2G = clr[1];
		scheme2B = clr[2];
		scheme2Color = Convert.colorFloat(scheme2R, scheme2G, scheme2B);
	}
	
	public function updateTime():Void
	{
		var date:Date = Date.now();
		time_year = date.getFullYear();
		time_month = date.getMonth() + 1;
		if (state_full.activeDay == null || (state_full.syncToday && date.getDate() != time_day)) {
			state_full.activeDay = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0); 
			state_full.timeLine.refreshMarkers(state_full.activeDay);
			state_full.checkConflict = true;
			if (state_full.mainMenu != null) {
				state_full.mainMenu.checkProject = true;
				state_full.mainMenu.refreshDateUI();
			}
		}
		time_day = date.getDate();
		time_weekday = date.getDay();
		if (time_weekday == 0) time_weekday = 7;
		if (date.getHours() != time_hour) {
			genSchemeColor();
			if (state_full.mainMenu != null) state_full.mainMenu.checkProject = true;
			rest = true;
		}
		time_hour = date.getHours();
		if (date.getMinutes() != time_minute) {
			//if (state_full.mainMenu != null) state_full.mainMenu.checkActiveTask = true;
		}
		time_minute = date.getMinutes();
		time_second = date.getSeconds();
		time_daysecond = time_hour * 3600 + time_minute * 60 + time_second;
		//trace(DateTools.make({ms:0,seconds:10,minutes:1,hours:2,days:1}));
	}
	
	public override function update():Void
	{
        //trace(a.data);
		updateTime();
	}
	
}