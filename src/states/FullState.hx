package states;

import engine.objects.AtlasEntity;
import objects.Clock;
import objects.Dialog;
import objects.info.*;
import objects.MainMenu;
import objects.primitive.UIButton;
import objects.MinimizeButton;
import engine.NRFDisplay;
import engine.display.AtlasTransformMode;
import objects.ProjectMenu;
import objects.TaskList;
import objects.TaskMarker;
import objects.TaskMenu;
import objects.TimeLine;
import screens.MainScreen;
import openfl.Lib;
import engine.utils.*;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.display.StageDisplayState;

/**
 * ...
 * @author TommyX
 */
class FullState extends State
{
	
	public static var current:FullState;
	public static var snapThreshold:Int = 5;
	public static var snapInterval:Int = 15;
	
	public var rightMouseHeld:Bool = false;
	public var rightMouseX:Float;
	
	public var activeDay:Date;
	public var syncToday:Bool;
	
	public var alerts:Array<String>;
	
	public var timeLine:TimeLine;
	public var minimizeBtn:MinimizeButton;
	public var clock:Clock;
	
	public var timeLineScaleDest:Float;
	
	public var focusLevel:Int;
	
	public var taskMenu:TaskMenu;
	public var mainMenu:MainMenu;
	public var taskList:TaskList;
	public var projectMenu:ProjectMenu;
	
	public var newSchedule:Int;
	public var newScheduleM:TaskMarker;
	public var newScheduleSM:Int;
	public var newScheduleEM:Int;
	
	public var dialog:Dialog;
	
	public var checkConflict:Bool;

	public function new() 
	{
		super();
		
		syncToday = true;
		
		checkConflict = true;
		
		alerts = new Array<String>();
		
		current = this;
		
		timeLine = new TimeLine(this);
		timeLine.pos.copyXY(80, NRFDisplay.centerHeight);
		timeLine.transformMode = AtlasTransformMode.GLOBAL;
		addChild(timeLine);
		
		timeLineScaleDest = 1;
		
		focusLevel = 0;
		
		minimizeBtn = new MinimizeButton(this);
		minimizeBtn.transformMode = AtlasTransformMode.GLOBAL;
		addChild(minimizeBtn);
		
		clock = new Clock(this);
		clock.transformMode = AtlasTransformMode.GLOBAL;
		addChild(clock);
		
		newSchedule = 0;
		newScheduleM = new TaskMarker(this);
		newScheduleM.visible = false;
		newScheduleM.buttonEnabled = false;
		newScheduleM.transformMode = AtlasTransformMode.LOCAL;
		timeLine.addChild(newScheduleM);
		timeLine.addChild(timeLine.pointer);
		
		showMainMenu();
	}
	
	public function showTaskMenu(marker:TaskMarker, _task:Task = null):Void
	{
		if (dialog != null) dialog.remove();
		if (taskMenu != null) taskMenu.remove();
		taskMenu = new TaskMenu(this, 600, 800, false, marker, _task);
		taskMenu.transformMode = AtlasTransformMode.GLOBAL;
		focusLevel = -1;
		addChild(taskMenu);
	}
	
	public function showProjectMenu(project:Project):Void
	{
		projectMenu = new ProjectMenu(this, project);
		projectMenu.transformMode = AtlasTransformMode.GLOBAL;
		projectMenu.pos.y = NRFDisplay.centerHeight;
		focusLevel = 1;
		addChild(projectMenu);
	}
	
	public function showMainMenu():Void
	{
		if (dialog != null) dialog.remove();
		if (taskMenu != null) taskMenu.remove();
		if (projectMenu != null) projectMenu.remove();
		if (taskList != null) taskList.remove();
		if (mainMenu == null) {
			mainMenu = new MainMenu(this);
			mainMenu.transformMode = AtlasTransformMode.GLOBAL;
			focusLevel = -1;
			addChild(mainMenu);
		}
	}
	
	public function showTaskList(add:Bool = false, edit4Task:Task = null):Void
	{
		taskList = new TaskList(this, add, edit4Task);
		taskList.transformMode = AtlasTransformMode.GLOBAL;
		focusLevel = 1;
		addChild(taskList);
	}
	
	public function showDialog(type:String, prompt:String, options:Array<Dynamic>, handler:Dynamic, noCancel:Bool=false):Void
	{
		focusLevel = 0;
		dialog = new Dialog(this, type, prompt, options, handler, noCancel);
		dialog.transformMode = AtlasTransformMode.GLOBAL;
		addChild(dialog);
	}
	
	public override function update():Void
	{
		if (activated) {
			MainScreen.current.state_mini.alerted = false;
			minimizeBtn.pos.copyXY(NRFDisplay.currentWidth - 40, 40);
			timeLine.pointer.scaleY = 1 / timeLine.scaleY;
			if (Input.rightMouseDown && !rightMouseHeld) {
				rightMouseX = Input.mousePos.x;
			}
			rightMouseHeld = Input.rightMouseDown;
			if (focusLevel <= 0) {
				if (Input.mousePos.x <= 500) timeLineScaleDest = Math.min(Math.max(timeLineScaleDest + Input.mouseWheel * 0.4, 1), 5);
				if (Input.rightMouseDown) timeLineScaleDest = Math.min(Math.max(timeLineScaleDest + (Input.mousePos.x - rightMouseX) * 0.01, 1), 5);
			}
			rightMouseX = Input.mousePos.x;
			timeLine.scaleY += (timeLineScaleDest - timeLine.scaleY) * 0.5;
			timeLine.pos.y = Util.map(Input.mousePos.y, 0, NRFDisplay.currentHeight, 100, NRFDisplay.currentHeight - TimeLine.length * timeLine.scaleY - 100);
			clock.pos.copyXY(NRFDisplay.currentWidth - 80, 10);
			if (mainMenu != null) {
				mainMenu.pos.copyXY(NRFDisplay.centerWidth, NRFDisplay.centerHeight-40);
				if (mainMenu.parent == null) mainMenu = null;
			}
			if (taskMenu != null) {
				taskMenu.pos.copyXY(NRFDisplay.centerWidth + (NRFDisplay.currentWidth - NRFDisplay.centerWidth) * 0.35, NRFDisplay.centerHeight - 10);
				if (taskMenu.parent == null) taskMenu = null;
			}
			if (taskList != null) {
				taskList.pos.copyXY(NRFDisplay.centerWidth + (NRFDisplay.currentWidth - NRFDisplay.centerWidth) * 0.4, NRFDisplay.centerHeight);
				if (taskList.parent == null) taskList = null;
			}
			if (dialog != null) {
				dialog.pos.copyXY(NRFDisplay.centerWidth + (NRFDisplay.currentWidth - NRFDisplay.centerWidth) * 0.4, NRFDisplay.centerHeight);
				if (dialog.parent == null) dialog = null;
			}
			if (projectMenu != null) {
				projectMenu.pos.x = NRFDisplay.centerWidth + (NRFDisplay.currentWidth - NRFDisplay.centerWidth) * 0.35;
				if (projectMenu.parent == null) projectMenu = null;
			}
			if (minimizeBtn.released) {
				showMainMenu();
				MainScreen.current.state_mini.show();
				Lib.current.stage.displayState = StageDisplayState.NORMAL;
				hide();
			}
			if (newSchedule > 0) {
				if (newSchedule > 1){
					if (Input.mousePos.x < timeLine.pos.x + 500) {
						if (Input.mousePressed){
							newScheduleM.visible = true;
							newScheduleSM = Math.round(Math.min(Math.max(Util.map(Input.mousePos.y, timeLine.pos.y, timeLine.pos.y + timeLine.scaleY * TimeLine.length, 0, 1440), 0), 1440));
							var snap:Bool = false;
							for (marker in timeLine.markers) {
								if (Math.abs(newScheduleSM - marker.startMinute) < snapThreshold) {
									newScheduleSM = marker.startMinute-1;
									snap = true;
									break;
								}
								if (Math.abs(newScheduleSM - marker.endMinute) < snapThreshold) {
									newScheduleSM = marker.endMinute+1;
									snap = true;
									break;
								}
							}
							if (!snap) {
								for (i in -4...5) {
									if ((newScheduleSM + i) % snapInterval == 0) {
										newScheduleSM = Math.round(newScheduleSM/snapInterval)*snapInterval;
									}
								}
							}
						}
						if (Input.mouseDown) {
							newScheduleEM = Math.round(Math.min(Math.max(Util.map(Input.mousePos.y, timeLine.pos.y, timeLine.pos.y + timeLine.scaleY * TimeLine.length, 0, 1440), 0), 1440));
							var snap:Bool = false;
							for (marker in timeLine.markers) {
								if (Math.abs(newScheduleEM - marker.startMinute) < 10) {
									newScheduleEM = marker.startMinute-1;
									snap = true;
									break;
								}
								if (Math.abs(newScheduleEM - marker.endMinute) < 10) {
									newScheduleEM = marker.endMinute+1;
									snap = true;
									break;
								}
							}
							if (!snap) {
								for (i in -4...5) {
									if ((newScheduleEM + i) % snapInterval == 0) {
										newScheduleEM = Math.round(newScheduleEM/snapInterval)*snapInterval;
									}
								}
							}
						}
						newScheduleM.setTime(newScheduleSM, newScheduleEM);
					}
				}
			}
			else {
				newScheduleM.visible = false;
			}
		}
	}
	
}