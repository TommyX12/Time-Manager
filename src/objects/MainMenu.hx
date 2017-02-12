package objects;

import objects.primitive.UIContainer;
import objects.primitive.UIText;
import states.State;
import objects.primitive.UIButton;
import engine.utils.*;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import screens.MainScreen;
import engine.display.AtlasTransformMode;
import states.FullState;
import objects.info.*;
import engine.NRFDisplay;

/**
 * ...
 * @author TommyX
 */
class MainMenu extends UIContainer
{
	
	//overview menu
	//active goals menu
	
	public var addBtn:UIButton;
	public var dateBtn:UIButton;
	public var todayBtn:UIButton;
	public var alertBtn:UIButton;
	public var listBtn:UIButton;
	public var autoBtn:UIButton;
	public var dateLBtn:UIButton;
	public var dateRBtn:UIButton;
	
	public var timer:UIText;
	public var activeTaskTxt:UIText;
	
	public var flashingR:Float = 20;
	public var flashingP:Float = 0;
	
	public var checkProject:Bool;
	public var checkActiveTask:Bool;
	
	public var isFreeSection:Bool;
	public var activeTask:Task;
	public var endTime:Int;
	
	public var cacheCurSecond:Int;
	public var cacheCurDay:Int;
	
	public var activeTaskMenu:TaskMenu;
	
	public var firstAlert:Bool;
	
	public var conflictTxt:UIText;
	public var dstatusTxt:UIText;
	
	public var dstatus:String;
	public var dstatusCnt:Int;
	
	private var dstatusCntMax:Int = 1024;

	public function new(state:State) 
	{
		super(state);
		
		var btnPosX:Float = 00;
		var btnPosY:Float = -50;
		
		addBtn = new UIButton(state, "_add");
		addBtn.transformMode = AtlasTransformMode.LOCAL;
		addBtn.pos.copyXY(btnPosX,btnPosY-70);
		addBtn.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 36, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
		addBtn.height = addBtn.width = 120;
		addBtn.setTextWidth(200);
		addBtn.setTextHeight(100);
		addBtn.textPos.addXYSelf(0, addBtn.height / 2 + 60);
		addBtn.text.textColor = 0x000000;
		addBtn.text.text = "Add Task";
		addBtn.colorTheme = 2;
		addChild(addBtn);
		
		autoBtn = new BoxButton(state, "Auto Schedule");
		autoBtn.transformMode = AtlasTransformMode.LOCAL;
		autoBtn.pos.copyXY(btnPosX,btnPosY+120);
		addChild(autoBtn);
		
		dateBtn = new BoxButton(state, " Select Date ");
		dateBtn.transformMode = AtlasTransformMode.LOCAL;
		dateBtn.pos.copyXY(btnPosX, btnPosY-200);
		dateBtn.text.text = "";
		addChild(dateBtn);
		
		dateLBtn = new UIButton(state, "_arrow");
		dateLBtn.transformMode = AtlasTransformMode.LOCAL;
		dateLBtn.pos.copy(dateBtn.pos);
		dateLBtn.pos.addXYSelf(-dateBtn.width/2-32, 0);
		dateLBtn.width = dateLBtn.height = dateBtn.height;
		dateLBtn.rotation = 180;
		dateLBtn.text.text = "";
		addChild(dateLBtn);
		
		dateRBtn = new UIButton(state, "_arrow");
		dateRBtn.transformMode = AtlasTransformMode.LOCAL;
		dateRBtn.pos.copy(dateBtn.pos);
		dateRBtn.pos.addXYSelf(dateBtn.width/2+32, 0);
		dateRBtn.width = dateRBtn.height = dateBtn.height;
		dateRBtn.text.text = "";
		addChild(dateRBtn);
		
		todayBtn = new BoxButton(state, "Back to Today");
		todayBtn.transformMode = AtlasTransformMode.LOCAL;
		todayBtn.pos.copyXY(btnPosX, btnPosY-280);
		todayBtn.visible = false;
		addChild(todayBtn);
		
		alertBtn = new BoxButton(state, "   Alerts   ");
		alertBtn.transformMode = AtlasTransformMode.LOCAL;
		alertBtn.pos.copyXY(btnPosX,btnPosY+300);
		addChild(alertBtn);
		
		listBtn = new BoxButton(state, "All Tasks");
		listBtn.transformMode = AtlasTransformMode.LOCAL;
		listBtn.pos.copyXY(btnPosX,btnPosY+200);
		addChild(listBtn);
		
		timer = new UIText(state);
		timer.transformMode = AtlasTransformMode.LOCAL;
		timer.pos.copyXY(500, -325);
		timer.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 36, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
		timer.setTextWidth(200);
		timer.setTextHeight(100);
		addChild(timer);
		
		activeTaskTxt = new UIText(state);
		activeTaskTxt.transformMode = AtlasTransformMode.LOCAL;
		activeTaskTxt.pos.copyXY(500, -255);
		activeTaskTxt.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 36, 0x000000, false, null, null, null, null, TextFormatAlign.CENTER);
		activeTaskTxt.setTextWidth(300);
		activeTaskTxt.setTextHeight(100);
		addChild(activeTaskTxt);
		
		cacheCurSecond = -1;
		cacheCurDay = -1;
		
		checkProject = true;
		checkActiveTask = true;
		
		firstAlert = true;
		
		refreshDateUI();
		
		MainScreen.hasConflict = false;
		conflictTxt = null;
	
		dstatus = "";
		dstatusCnt = 0;
		
		dstatusTxt = new UIText(state);
		dstatusTxt.transformMode = AtlasTransformMode.LOCAL;
		dstatusTxt.pos.copyXY(btnPosX, btnPosY+350);
		dstatusTxt.setTextWidth(500);
		dstatusTxt.text.height = 200;
		dstatusTxt.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 26, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
		addChild(dstatusTxt);
		dstatusTxt.text.border = true;
		dstatusTxt.text.selectable = true;
	}
	
	public override function update():Void
	{
		if (FullState.current.checkConflict && !MainScreen.hasConflict) {
			//var conflicts:Array<Array<Dynamic>> = [];
			var found:Bool = false;
			var markers:Array<TaskMarker> = FullState.current.timeLine.markers;
			for (i in 1...markers.length) {
				var ma:TaskMarker = markers[i];
				for (j in 0...i) {
					var mb:TaskMarker = markers[j];
					if ((ma.startMinute >= mb.startMinute && ma.startMinute <= mb.endMinute) || (ma.endMinute >= mb.startMinute && ma.endMinute <= mb.endMinute) || (mb.startMinute >= ma.startMinute && mb.startMinute <= ma.endMinute) || (mb.endMinute >= ma.startMinute && mb.endMinute <= ma.endMinute)) {
						found = true;
						//trace(ma.startMinute, ma.endMinute, mb.startMinute, mb.endMinute);
						break;
					}
				}
				if (found) break;
			}
			if (found) {
				MainScreen.hasConflict = true;
				if (activeTaskMenu != null) {
					activeTaskMenu.remove();
					activeTaskMenu = null;
				}
			}
			else {
				FullState.current.checkConflict = false;
			}
		}
		if (addBtn.released) {
			FullState.current.showTaskList(true);
			remove();
			return;
		}
		if (listBtn.released) {
			FullState.current.showTaskList();
			remove();
			return;
		}
		if (dateBtn.released) {
			FullState.current.showDialog(DialogType.DATE, "Enter the year, month and date.", [], d_dateSelect);
			remove();
			return;
		}
		if (dateLBtn.released) {
			var _year:Int = FullState.current.activeDay.getFullYear();
			var _month:Int = FullState.current.activeDay.getMonth()+1;
			var _day:Int = FullState.current.activeDay.getDate() - 1;
			if (_day < 1) _month--;
			if (_month < 1) {
				_year--;
				_month = 12;
			}
			if (_year >= 2000) {
				if (_day < 1) _day = DateTools.getMonthDays(new Date(_year, _month - 1, 1, 0, 0, 0));
				setDate(_year, _month, _day);
				refreshDateUI();
			}
		}
		if (dateRBtn.released) {
			var _year:Int = FullState.current.activeDay.getFullYear();
			var _month:Int = FullState.current.activeDay.getMonth()+1;
			var _day:Int = FullState.current.activeDay.getDate() + 1;
			var _date:Int = DateTools.getMonthDays(new Date(_year, _month - 1, 1, 0, 0, 0));
			if (_day > _date) _month++;
			if (_month > 12) {
				_year++;
				_month = 1;
			}
			if (_year <= 2099) {
				if (_day > _date) _day = 1;
				setDate(_year, _month, _day);
				refreshDateUI();
			}
		}
		if (autoBtn.released) {
			d_autoschd();
			remove();
			return;
		}
		if (!FullState.current.syncToday) {
			if (todayBtn.released) {
				FullState.current.activeDay = new Date(MainScreen.current.time_year, MainScreen.current.time_month-1, MainScreen.current.time_day, 0, 0, 0);
				FullState.current.syncToday = true;
				FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
				FullState.current.checkConflict = true;
				refreshDateUI();
			}
		}
		if (checkProject && MainScreen.current.time_day != -1) {
			FullState.current.alerts = [];
			dstatus = "";
			dstatusCnt = 0;
			
			var f:Array<Int> = new Array<Int>();
			for (i in 0...366) {
				f.push(0);
			}
			
			var pn:Array<Array<String>> = new Array<Array<String>>();
			for (i in 0...366) {
				pn.push(new Array<String>());
			}
			
			var gt:Array<Task> = [];
			
			var inf:Int = 10000000;
			var minFreeTime:Int = inf;
			
			for (task in MainScreen.data_tasks) {
				if (task.goalType == "project"){
					var project:Project = cast task;
					var required:Int = 0;
					for (i in 0...Convert.int(project.subtasks.length / 2)) {
						var a:Int = project.subtasks[i * 2];
						if (a == -1) {
							var ot:Float = new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day, 0, 0, 0).getTime();
							var nt:Float = project.subtasks[i * 2 + 1].getTime();
							var diff:Int = Math.round((nt - ot) / 86400000);
							if (diff >= 0 && diff <= 365) {
								f[diff] += required;
								pn[diff].push("["+project.name+"]");
								required = 0;
							}
						}
						else required += a;
					}
				}
				else if (task.goalType == "repeat") {
					gt.push(task);
				}
			}
			
			var ft:Int = 0;
			for (i in 0...f.length) {
				ft -= f[i];
				if (f[i] > 0){
					if (dstatusCnt < dstatusCntMax) {
						for (pname in pn[i]) {
							dstatus += pname + " ";
						}
						minFreeTime = Convert.int(Math.min(ft, minFreeTime));
						if (ft >= 0) {
							var fth:Int = Math.floor(ft / 60);
							var ftm:Int = ft % 60;
							dstatus += new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day + i - 1, 23, 59, 59).toString() + " - " + Convert.string(fth) + ":" + Convert.string(ftm) + "\n";  
							dstatusCnt++;
						}
						else {
							var fth:Int = Math.floor(-ft / 60);
							var ftm:Int = -ft % 60;
							dstatus += new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day + i - 1, 23, 59, 59).toString() + " - -" + Convert.string(fth) + ":" + Convert.string(ftm) + "\n";  
							dstatusCnt++;
						}
					}
				}
				if (ft < 0) {
					for (pname in pn[i]){
						FullState.current.alerts.push("You will not be able to finish project " + pname + " before deadline " + new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day + i - 1, 23, 59, 59).toString() + ".");
					}
					ft = 0;
				}
				var ftd:Int = 1440;
				for (task in gt) {
					task.goalTemp = task.goal;
				}
				if (i == 0) {
					var cur:Int = MainScreen.current.time_hour * 60 + MainScreen.current.time_minute;
					ftd -= cur;
					for (task in MainScreen.data_tasks) {
						var isProject:Bool = task.goalType == "project";
						for (schedule in task.schedules) {
							if (TimeLine.scheduleTest(schedule, new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day + i, 0, 0, 0).getTime())) {
								var sm = Math.max(cur, schedule.startMinute);
								var em = Math.max(cur, schedule.endMinute);
								if (!isProject) {
									ftd -= Convert.int(Math.abs(em - sm));
									if (task.goalType == "repeat") {
										if (task.goalTemp > schedule.endMinute - schedule.startMinute) task.goalTemp -= schedule.endMinute - schedule.startMinute; else task.goalTemp = 0;
									}
								}
							}
						}
					}
				}
				else {
					for (task in MainScreen.data_tasks) {
						var isProject:Bool = task.goalType == "project";
						for (schedule in task.schedules) {
							if (TimeLine.scheduleTest(schedule, new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day + i, 0, 0, 0).getTime())) {
								if (!isProject) {
									var dur:Int = schedule.endMinute - schedule.startMinute;
									ftd -= Convert.int(Math.abs(dur));
									if (task.goalType == "repeat") {
										if (task.goalTemp > dur) task.goalTemp -= dur; else task.goalTemp = 0;
									}
								}
							}
						}
					}
				}
				for (task in gt) {
					ftd -= task.goalTemp;
				}
				if (ftd < 0) ftd = 0;
				ft += ftd;
				f[i] = ft;
			}
			
			if (minFreeTime != inf) {
				var frontStr:String = "Free time before Deadlines:\nMinimum Free Time - ";
				if (minFreeTime >= 0) {
					var fth:Int = Math.floor(minFreeTime / 60);
					var ftm:Int = minFreeTime % 60;
					frontStr += Convert.string(fth) + ":" + Convert.string(ftm) + "\n";  
				}
				else {
					var fth:Int = Math.floor(-minFreeTime / 60);
					var ftm:Int = -minFreeTime % 60;
					frontStr += "-" + Convert.string(fth) + ":" + Convert.string(ftm) + "\n";  
				}
				dstatus = frontStr + dstatus;
			}
			
			checkProject = false;
			if (FullState.current.alerts[0] != null) {
				alertBtn.text.text = "Alerts - " + Convert.string(FullState.current.alerts.length);
			}
			if (dstatusCnt>0) dstatusTxt.text.text = dstatus;
			else dstatusTxt.text.text = "";
		}
		if (FullState.current.alerts[0] != null) {
			if (flashingP >= flashingR) {
				if (alertBtn.colorTheme == 2) alertBtn.colorTheme = 1;
				else {
					alertBtn.colorTheme = 2;
				}
				flashingP -= flashingR;
			}
			flashingP++;
			if (alertBtn.released) {
				alertPointer = -1;
				d_alert(null, 1);
				remove();
				return;
			}
		}
		else {
			alertBtn.colorTheme = 1;
		}
		if (MainScreen.current.rest) {
			if (MainScreen.current.state_full.activated){
				d_rest();
				remove();
				return;
			}
			else if (!MainScreen.current.state_mini.alerted) {
				MainScreen.current.state_mini.alerted = true;
				MainScreen.alert(gen_rest_prompt(), "Break Notification");
			}	
		}
		var curTime:Int = MainScreen.current.time_daysecond;
		if (MainScreen.hasConflict) {
			if (conflictTxt == null) {
				conflictTxt = new UIText(state);
				conflictTxt.transformMode = AtlasTransformMode.GLOBAL;
				conflictTxt.pos.copyXY(1186, 368);
				conflictTxt.text.width = 400;
				conflictTxt.text.height = 400;
				conflictTxt.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 42, 0x000000, true, null, null, null, null, TextFormatAlign.LEFT);
				conflictTxt.text.text = "There is one or more conflict in the schedules. Please remove as soon as possible for the system to function correctly.";
				addChild(conflictTxt);
			}
		}
		else if (checkActiveTask || endTime < curTime || MainScreen.current.time_day != cacheCurDay) {
			var curMinute:Float = MainScreen.current.time_daysecond / 60;
			isFreeSection = true;
			endTime = 1440;
			activeTask = null;
			var time:Float = new Date(MainScreen.current.time_year, MainScreen.current.time_month-1, MainScreen.current.time_day, 0,0,0).getTime();
			for (task in MainScreen.data_tasks) {
				for (schedule in task.schedules) if (TimeLine.scheduleTest(schedule, time)){
					if (curMinute >= schedule.startMinute && curMinute <= schedule.endMinute) {
						activeTask = task;
						endTime = schedule.endMinute;
						isFreeSection = false;
						break;
					}
					else if (schedule.startMinute > curMinute && schedule.startMinute <= endTime) {
						activeTask = task;
						endTime = schedule.startMinute;
					}
				}
			}
			endTime *= 60;
			checkActiveTask = false;
			
			if (activeTaskMenu != null) {
				activeTaskMenu.remove();
			}
			if (activeTask == null) {
				activeTaskTxt.text.text = "";
			}
			else {
				activeTaskMenu = new TaskMenu(FullState.current, 450, 640, true, null, activeTask);
				addChild(activeTaskMenu);
				activeTaskMenu.transformMode = AtlasTransformMode.GLOBAL;
				if (isFreeSection) activeTaskTxt.text.text = "Upcoming Task:";
				else activeTaskTxt.text.text = "Current Task:";
			}
			cacheCurDay = MainScreen.current.time_day;
			if (!firstAlert && !FullState.current.activated){
				if (isFreeSection) MainScreen.alert("No active task.", "Task Notification");
				else MainScreen.alert("Current task: " + activeTask.name, "Task Notification");
				MainScreen.current.state_mini.alerted = true;
			}
			firstAlert = false;
		}
		if (activeTaskMenu != null) activeTaskMenu.pos.copyXY(pos.x + 500, pos.y + 105);
		if (curTime != cacheCurSecond) {
			if (MainScreen.hasConflict) {
				timer.visible = false;
				if (MainScreen.current.state_mini.activated) {
					MainScreen.current.state_mini.text.visible = false;
				}
			}
			else {
				timer.visible = true;
				timer.text.textColor = MainScreen.current.scheme2Color;
				var s:Int = endTime - curTime;
				var h:Int = Math.floor(s / 3600);
				s -= h * 3600;
				var m:Int = Math.floor(s / 60);
				s -= m * 60;
				timer.text.text = Util.getFileNameNumber(h, 2) + ":" + Util.getFileNameNumber(m, 2) + ":" + Util.getFileNameNumber(s, 2);
				if (MainScreen.current.state_mini.activated) {
					MainScreen.current.state_mini.text.visible = true;
					MainScreen.current.state_mini.text.text.textColor = !isFreeSection ? activeTaskMenu.bg.color : 0x000000;
					MainScreen.current.state_mini.text.text.text = timer.text.text;
				}
			}
			cacheCurSecond = curTime;
		}
		//stuffs
	}
	
	public function refreshDateUI():Void
	{
		if (!FullState.current.syncToday) {
			var weekday:Int = FullState.current.activeDay.getDay();
			if (weekday == 0) weekday = 7;
			dateBtn.text.text = Util.getFileNameNumber(FullState.current.activeDay.getFullYear(), 4)+"/"+Util.getFileNameNumber(FullState.current.activeDay.getMonth()+1, 2)+"/"+Util.getFileNameNumber(FullState.current.activeDay.getDate(), 2)+"-"+Convert.string(weekday);
			todayBtn.visible = true;
			autoBtn.visible = false;
		}
		else {
			dateBtn.text.text = " Select Date ";
			todayBtn.visible = false;
			autoBtn.visible = true;
		}
	}
	
	public static function setDate(year:Int, month:Int, day:Int):Void
	{
		if (!(year == FullState.current.activeDay.getFullYear() && month - 1 == FullState.current.activeDay.getMonth() && day == FullState.current.activeDay.getDate())) {
			if (year == MainScreen.current.time_year && month == MainScreen.current.time_month && day == MainScreen.current.time_day) {
				FullState.current.activeDay = new Date(year, month-1, day, 0, 0, 0);
				FullState.current.syncToday = true;
				FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
			}
			else {
				FullState.current.activeDay = new Date(year, month-1, day, 0, 0, 0);
				FullState.current.syncToday = false;
				FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
			}
			FullState.current.checkConflict = true;
		}
	}
	
	public static function d_dateSelect(year:Int, month:Int, day:Int):Void
	{
		setDate(year, month, day);
		FullState.current.showMainMenu();
	}
	
	public static var alertPointer:Int;
	public static function d_alert(a,b):Void
	{
		if (b == 1){
			alertPointer++;
			if (alertPointer >= FullState.current.alerts.length) FullState.current.showMainMenu();
			else FullState.current.showDialog(DialogType.SELECT, FullState.current.alerts[alertPointer], ["View Project", "Next"], d_alert);
		}
		else {
			var name:String = FullState.current.alerts[alertPointer].substring(FullState.current.alerts[alertPointer].indexOf("[") + 1, FullState.current.alerts[alertPointer].lastIndexOf("]"));
			for (task in MainScreen.data_tasks) {
				if (task.name == name) {
					FullState.current.showTaskMenu(null, task);
					break;
				}
			}
		}
	}
	
	public static function d_autoschd():Void
	{
		FullState.current.showDialog(DialogType.SELECT, "Standing by. What would you like to do today?", ["Projects + Task Goals", "Projects only", "Task Goals only", "Delete all generated schedules"], d_autoschdAlgorithm);
	}
	
	public static var autoschd_greedyMul:Float = 1.25;
	public static function d_autoschdAlgorithm(o, algorithm:Int):Void
	{
		if (algorithm == 3) {
			for (task in MainScreen.data_tasks) {
				var i:Int = 0;
				while (i < task.schedules.length) {
					if (task.schedules[i].isAuto) task.schedules.splice(i, 1);
					else i++;
				}
			}
		}
		else {
			var todaysGoal:Bool = true;
			var projects:Bool = true;
			if (algorithm == 1) todaysGoal = false;
			if (algorithm == 2) projects = false;
			
			var es_fse:Array<Int> = [];
			var ee_fss:Array<Int> = [];
			var req:Array<Task> = [];
			
			var f:Array<Array<Int>> = new Array<Array<Int>>();
			for (i in 0...366) {
				f.push([]);
			}
			
			var pn:Array<Array<Project>> = new Array<Array<Project>>();
			for (i in 0...366) {
				pn.push([]);
			}
			
			var gt:Array<Task> = [];
			
			for (task in MainScreen.data_tasks) {
				if (task.goalType == "project"){
					var project:Project = cast task;
					var required:Int = 0;
					for (i in 0...Convert.int(project.subtasks.length / 2)) {
						var a:Int = project.subtasks[i * 2];
						if (a == -1) {
							var ot:Float = new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day, 0, 0, 0).getTime();
							var nt:Float = project.subtasks[i * 2 + 1].getTime();
							var diff:Int = Math.round((nt - ot) / 86400000);
							if (diff >= 1 && diff <= 365) {
								f[diff].push(required);
								pn[diff].push(project);
								required = 0;
							}
						}
						else required += a;
					}
				}
				else if (task.goalType == "repeat") {
					gt.push(task);
				}
			}
			
			for (task in MainScreen.data_tasks) {
				task.goalTemp = 0;
			}
			var ft:Int = 0;
			var ftc:Int = 0;
			var cur:Int = MainScreen.current.time_hour * 60 + MainScreen.current.time_minute;
			for (i in 0...f.length) {
				var ftd:Int = 1440;
				for (task in gt) {
					task.goalTemp = task.goal;
				}
				if (i == 0) {
					ftd -= cur;
					for (task in MainScreen.data_tasks) {
						var isProject:Bool = task.goalType == "project";
						for (schedule in task.schedules) {
							if (TimeLine.scheduleTest(schedule, new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day, 0, 0, 0).getTime())) {
								var sm:Int = Convert.int(Math.max(cur, schedule.startMinute));
								var em:Int = Convert.int(Math.max(cur, schedule.endMinute));
								es_fse.push(sm);
								ee_fss.push(em);
								if (!isProject) {
									ftd -= Convert.int(Math.abs(em - sm));
									if (task.goalType == "repeat") {
										if (task.goalTemp > schedule.endMinute - schedule.startMinute) task.goalTemp -= schedule.endMinute - schedule.startMinute; else task.goalTemp = 0;
									}
								}
							}
						}
					}
				}
				else {
					for (task in MainScreen.data_tasks) {
						var isProject:Bool = task.goalType == "project";
						for (schedule in task.schedules) {
							if (TimeLine.scheduleTest(schedule, new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day + i, 0, 0, 0).getTime())) {
								if (!isProject) {
									var dur:Int = schedule.endMinute - schedule.startMinute;
									ftd -= Convert.int(Math.abs(dur));
									if (task.goalType == "repeat") {
										if (task.goalTemp > dur) task.goalTemp -= dur; else task.goalTemp = 0;
									}
								}
							}
						}
					}
				}
				if (i != 0 || (todaysGoal && FullState.current.alerts.length == 0)){
					for (task in gt) {
						ftd -= task.goalTemp;
					}
				}
				if (ftd < 0) ftd = 0;
				ft += ftd;
				if (i == 0) {
					ftc = ftd;
					//trace(ftc);
				}
				
				if (projects) {
					for (j in 0...f[i].length) {
						var value:Int = ft > 0 ? Math.floor(Math.min(f[i][j] / ft, 1) * ftc) : ftc;
						pn[i][j].goalTemp += Math.round(value * autoschd_greedyMul);
						ft -= f[i][j];
						ftc -= value;
						if (req.indexOf(pn[i][j]) == -1) req.push(pn[i][j]);
					}
					if (ft < 0) ft = 0;
				}
				else break;
			}
			for (task in MainScreen.data_tasks) {
				if (task.goalType != "project" && todaysGoal) {
					task.goalTemp = task.goal;
					req.push(task);
				}
				for (schedule in task.schedules) {
					if (TimeLine.scheduleTest(schedule, new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day, 0, 0, 0).getTime())) {
						var dur:Int = task.goalType == "project" ? Convert.int(Math.max(cur,schedule.endMinute) - Math.max(cur,schedule.startMinute)) : schedule.endMinute - schedule.startMinute;
						if (task.goalType == "repeat" || task.goalType == "project") {
							if (task.goalTemp > dur) task.goalTemp -= dur; else task.goalTemp = 0;
						}
					}
				}
			}
			/*
			for (task in MainScreen.data_tasks) {
				trace(task.name, task.goalTemp);
			}
			//*/
			
			es_fse.sort(d_autoschdSort);
			ee_fss.sort(d_autoschdSort);
			es_fse.push(1440);
			ee_fss.insert(0, cur);
			
			var i:Int = 0;
			while (i < es_fse.length) {
				if (es_fse[i] - ee_fss[i] < 15) {
					ee_fss.splice(i, 1);
					es_fse.splice(i, 1);
				}
				else {
					es_fse[i]--;
					i++;
				}
			}
			
			for (task in req) {
				task.goalTemp = Math.round(task.goalTemp / 15);
			}
			
			var taskPtr:Int = 0;
			while (taskPtr < req.length && ee_fss.length > 0) {
				var schedule:Schedule = new Schedule();
				schedule.start = new Date(MainScreen.current.time_year, MainScreen.current.time_month - 1, MainScreen.current.time_day, 0, 0, 0);
				schedule.startMinute = ee_fss[0] + 1;
				schedule.endMinute = ee_fss[0];
				schedule.numOfTimes = 1;
				schedule.isAuto = true;
				while (req[taskPtr].goalTemp > 0) {
					if (es_fse[0] - ee_fss[0] < 15) {
						if (es_fse[0] - ee_fss[0] == 14) {
							schedule.endMinute += 14;
							ee_fss[0] += 14;
							req[taskPtr].goalTemp--;
						}
						break;
					}
					schedule.endMinute += 15;
					ee_fss[0] += 15;
					req[taskPtr].goalTemp--;
				}
				if (es_fse[0] - ee_fss[0] < 15) {
					ee_fss.splice(0, 1);
					es_fse.splice(0, 1);
				}
				if (schedule.endMinute > schedule.startMinute) req[taskPtr].schedules.push(schedule);
				if (req[taskPtr].goalTemp == 0) taskPtr++;
			}
		}
		
		MainScreen.saveData();
		FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
		FullState.current.showMainMenu();
	}
	public static function d_autoschdSort(a:Int, b:Int):Int
	{
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	public static function gen_rest_prompt():String
	{
		//prompt
		var temp:Array<String> = [];
		temp.push(Util.randomInt(2) == 0 ? "you " : "");
		temp.push(Util.randomInt(2) == 0 ? "way " : "");
		temp.push(Util.randomInt(2) == 0 ? "stand up and " : "");
		temp.push(Util.randomInt(2) == 0 ? "around " : "");
		temp.push(Util.randomInt(2) == 0 ? "up " : "");
		temp.push(Util.randomInt(2) == 0 ? "a " : "some ");
		temp.push(Util.randomInt(2) == 0 ? "" : " now");
		temp.push(Util.randomInt(2) == 0 ? "too much " : "");
		temp.push(Util.randomInt(2) == 0 ? "not good " : "bad ");
		temp.push(Util.randomInt(2) == 0 ? " too" : " as well");
		var pre = [
			"",
			"Dont " + temp[0] + "forget, ",
			"Hey, ",
			"It's been an hour, ",
			"Another hour has passed, ",
			"Come on, ",
			"Look, ",
			"Listen, "
		];
		var body = [
			"",
			"you've been sitting " + temp[1] + "too long, ",
			"you've been working for a while" + temp[6] + ", ",
			"it's resting time, ",
			"sitting " + temp[7] + "is " + temp[8] + "for you, ",
		];
		var body2 = [
			"go " + temp[2] + "walk " + temp[3] + "for 5 minutes",
			"let's stand " + temp[4] + "and rest a bit",
			"time to stand up and take " + temp[5] + "rest",
		];
		var pro = [
			".",
			". Just DO IT.",
			", it's good for you.",
			", I assume you wanna live longer.",
			", no joke."
		];
		var extra = [
			"",
			" And get some water" + temp[9] + ".",
		];
		return pre[Util.randomInt(pre.length)] + body[Util.randomInt(body.length)] + body2[Util.randomInt(body2.length)] + pro[Util.randomInt(pro.length)] + extra[Util.randomInt(extra.length)];
		
	}
	public static function d_rest():Void
	{
		var selYes:String = "I will do it now";
		var selNo:String = "Nope, I'm stupid";
		//selYes
		//selNo
		FullState.current.showDialog(DialogType.SELECT, gen_rest_prompt(), [selYes, selNo], d_rest_select, true);
	}
	public static function d_rest_select(a, b):Void
	{
		if (b == 0) d_rest_yes();
		else d_rest_no();
	}
	public static function d_rest_yes():Void
	{
		FullState.current.showDialog(DialogType.SELECT, "Good call.", ["Got it"], "exit", true);
		MainScreen.current.rest = false;
	}
	public static function d_rest_no():Void
	{
		var prompt:String = "";
		var selYes:String = "I will do it now";
		var selNo:String = "Nope, I'm stupid";
		//prompt
		var temp:Array<String> = [];
		temp.push(Util.randomInt(2) == 0 ? "just " : "");
		temp.push(Util.randomInt(2) == 0 ? "now " : "");
		temp.push(Util.randomInt(2) == 0 ? "from sitting " : "");
		var pre = [
			"",
			"What did you say?! ",
			"Well, ",
			"Well guess what, ",
			"I am not kidding, "
		];
		var body = [
			"your risk of heart disease has " + temp[0] + "increased by up to 64 percent",
			"you're shaving off seven years of quality life",
			"you're " + temp[1] + "more at risk for certain types of cancer",
			"simply put, sitting is killing you",
			"your overall risk of prostate or breast cancer has " + temp[0] + "increased by 30 percent",
			"short breaks " + temp[2] + "once an hour can alleviate most of the problems"
		];
		var pro = [
			".",
			". Just DO IT.",
			", no joke.",
			", you better get your ass up."
		];
		prompt = pre[Util.randomInt(pre.length)] + body[Util.randomInt(body.length)] + pro[Util.randomInt(pro.length)];
		//selYes
		//selNo
		FullState.current.showDialog(DialogType.SELECT, prompt, [selYes], d_rest_select, true);
	}
	
}