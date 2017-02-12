package objects;

import engine.display.AtlasDisplay;
import engine.objects.AtlasContainer;
import engine.objects.AtlasEntity;
import engine.display.AtlasTransformMode;
import engine.utils.Grid;
import objects.info.Project;
import objects.info.Schedule;
import objects.info.Task;
import objects.primitive.UIContainer;
import openfl.text.*;
import objects.primitive.UIText;
import objects.primitive.UITextbox;
import sys.FileSystem;
import screens.MainScreen;
import states.State;
import states.FullState;
import engine.utils.*;

/**
 * ...
 * @author TommyX
 */
class TaskMenu extends UIContainer
{
	
	public static var goalRestriction:EReg = new EReg("[^0-9]", "i");
	
	public var bg:AtlasEntity;
	public var name_txt:UIText;
	public var name_box:UIText;
	public var type_txt:UIText;
	public var type_box:UIText;
	public var note_txt:UIText;
	public var note_box:UIText;
	public var goal_txt:UIText;
	public var goal_box:UIText;
	
	public var task:Task;
	public var project:Project;
	public var schedule:Schedule;
	
	public var backBtn:BoxButton;
	public var deleteBtn:BoxButton;
	public var editType:BoxButton;
	public var editGoal:BoxButton;
	
	public var sdeleteBtn:BoxButton;
	public var scancelBtn:BoxButton;
	public var sendBtn:BoxButton;
	
	public var psubtaskBtn:BoxButton;
	
	public var noBtn:Bool;

	public function new(state:State, w:Float, h:Float, noBtn:Bool, marker:TaskMarker, _task:Task) 
	{
		super(state);
		
		bg = new AtlasEntity(layer, "_block");
		bg.transformMode = AtlasTransformMode.LOCAL;
		bg.width = w;
		bg.height = h;
		bg.alpha = 0.75;
		addChild(bg);
		
		this.noBtn = noBtn;
		
		if (marker != null){
			task = marker.task;
			schedule = marker.schedule;
			bg.r = marker.r * 0.6;
			bg.g = marker.g * 0.6;
			bg.b = marker.b * 0.6;
		}
		else {
			task = _task;
			bg.color = MainScreen.data_tasktypes_color[MainScreen.data_tasktypes_name.indexOf(task.type)];
			bg.r *= 0.6;
			bg.g *= 0.6;
			bg.b *= 0.6;
		}
		
		if (task.goalType == "project") {
			project = cast task;
		}
		
		if (!noBtn){
			deleteBtn = new BoxButton(state, "Delete");
			deleteBtn.transformMode = AtlasTransformMode.LOCAL;
			deleteBtn.colorTheme = 2;
			deleteBtn.pos.copyXY(0, 340);
			addChild(deleteBtn);
			
			backBtn = new BoxButton(state, "Back");
			backBtn.pos.copyXY(0, 440);
		}
		else {
			backBtn = new BoxButton(state, "Save");
			backBtn.pos.copyXY(0, h/2+50);
		}
		backBtn.transformMode = AtlasTransformMode.LOCAL;
		backBtn.colorTheme = 2;
		addChild(backBtn);
		
		
		name_txt = new UIText(state);
		name_txt.transformMode = AtlasTransformMode.LOCAL;
		name_txt.pos.copyXY( -w / 2+5, -h / 2+5);
		name_txt.text.textColor = 0xFFFFFF;
		name_txt.text.text = "Name:";
		addChild(name_txt);
		
		name_box = new UIText(state);
		name_box.transformMode = AtlasTransformMode.LOCAL;
		name_box.pos.copy(name_txt.pos.addXY(100, 5));
		name_box.text.border = true;
		name_box.text.type = TextFieldType.INPUT;
		name_box.text.maxChars = MainScreen.TASK_NAME_MAXCHARS;
		name_box.text.borderColor = 0xFFFFFF;
		name_box.text.multiline = false;
		name_box.text.textColor = 0xFFFFFF;
		name_box.text.width = w - 115;
		name_box.text.height = 42;
		name_box.text.selectable = true;
		name_box.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
		name_box.text.text = task.name;
		name_box.text.wordWrap = false;
		addChild(name_box);
		
		type_txt = new UIText(state);
		type_txt.transformMode = AtlasTransformMode.LOCAL;
		type_txt.pos.copy(name_txt.pos.addXY(0, 60));
		type_txt.text.textColor = 0xFFFFFF;
		type_txt.text.text = "Type:";
		addChild(type_txt);
		
		type_box = new UIText(state);
		type_box.transformMode = AtlasTransformMode.LOCAL;
		type_box.pos.copy(type_txt.pos.addXY(100, 5));
		type_box.text.border = true;
		type_box.text.borderColor = 0xFFFFFF;
		type_box.text.multiline = false;
		type_box.text.textColor = 0xFFFFFF;
		type_box.text.width = w - 235;
		type_box.text.height = 42;
		type_box.text.selectable = true;
		type_box.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, false, null, null, null, null, TextFormatAlign.CENTER);
		type_box.text.text = task.type;
		type_box.text.wordWrap = false;
		addChild(type_box);
		
		editType = new BoxButton(state, "Edit");
		editType.transformMode = AtlasTransformMode.LOCAL;
		editType.colorTheme = 2;
		editType.pos.copyXY(w/2 - 64, type_txt.pos.y + 25);
		addChild(editType);
		
		note_txt = new UIText(state);
		note_txt.transformMode = AtlasTransformMode.LOCAL;
		note_txt.pos.copy(type_txt.pos.addXY(0, 60));
		note_txt.text.textColor = 0xFFFFFF;
		note_txt.text.text = "Note:";
		addChild(note_txt);
		
		note_box = new UIText(state);
		note_box.transformMode = AtlasTransformMode.LOCAL;
		note_box.pos.copy(note_txt.pos.addXY(100, 5));
		note_box.text.type = TextFieldType.INPUT;
		note_box.text.maxChars = MainScreen.TASK_NOTE_MAXCHARS;
		note_box.text.border = true;
		note_box.text.borderColor = 0xFFFFFF;
		note_box.text.multiline = true;
		note_box.text.textColor = 0xFFFFFF;
		note_box.text.width = w - 115;
		note_box.text.height = 342;
		note_box.text.selectable = true;
		note_box.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 20, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.LEFT);
		note_box.text.text = task.note;
		note_box.text.wordWrap = true;
		addChild(note_box);
		
		goal_txt = new UIText(state);
		goal_txt.transformMode = AtlasTransformMode.LOCAL;
		goal_txt.pos.copy(note_txt.pos.addXY(0, 360));
		goal_txt.text.textColor = 0xFFFFFF;
		goal_txt.text.text = "Goal:";
		addChild(goal_txt);
		
		goal_box = new UIText(state);
		goal_box.transformMode = AtlasTransformMode.LOCAL;
		goal_box.pos.copy(goal_txt.pos.addXY(100, 5));
		goal_box.text.border = true;
		goal_box.text.borderColor = 0xFFFFFF;
		goal_box.text.multiline = false;
		goal_box.text.textColor = 0xFFFFFF;
		goal_box.text.width = task.goalType == "project" ? w - 115 : w - 235;
		goal_box.text.height = 42;
		goal_box.text.selectable = true;
		goal_box.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, false, null, null, null, null, TextFormatAlign.CENTER);
		if (task.goalType == "project") goal_box.text.text = "(Deadlines)";
		else if (task.goalType == "none") goal_box.text.text = "(None)";
		else if (task.goalType == "repeat") {
			var h:Int = Math.floor(task.goal / 60);
			var m:Int = Math.floor(task.goal - 60 * h);
			goal_box.text.text = Convert.string(h) + "h" + Convert.string(m) + "min daily";
		}
		goal_box.text.wordWrap = false;
		addChild(goal_box);
		
		if (task.goalType != "project") {
			editGoal = new BoxButton(state, "Edit");
			editGoal.transformMode = AtlasTransformMode.LOCAL;
			editGoal.colorTheme = 2;
			editGoal.pos.copyXY(w/2 - 64, goal_txt.pos.y + 25);
			addChild(editGoal);
		}
		
		if (schedule != null) {
			sdeleteBtn = new BoxButton(state, "Delete");
			sdeleteBtn.transformMode = AtlasTransformMode.LOCAL;
			sdeleteBtn.colorTheme = 2;
			sdeleteBtn.pos.copyXY(-400, -21);
			addChild(sdeleteBtn);
			
			if (schedule.numOfTimes != 1){
				scancelBtn = new BoxButton(state, "Skip");
				scancelBtn.transformMode = AtlasTransformMode.LOCAL;
				scancelBtn.colorTheme = 2;
				scancelBtn.pos.copyXY(-400, 60);
				addChild(scancelBtn);
				
				sendBtn = new BoxButton(state, "End");
				sendBtn.transformMode = AtlasTransformMode.LOCAL;
				sendBtn.colorTheme = 2;
				sendBtn.pos.copyXY(-400, 141);
				addChild(sendBtn);
			}
			else if (schedule.isAuto) {
				scancelBtn = new BoxButton(state, "Convert");
				scancelBtn.transformMode = AtlasTransformMode.LOCAL;
				scancelBtn.colorTheme = 2;
				scancelBtn.pos.copyXY(-400, 60);
				addChild(scancelBtn);
			}
			
			var stext:UIText = new UIText(state);
			stext.transformMode = AtlasTransformMode.LOCAL;
			stext.pos.copyXY( -400, -100);
			stext.setTextWidth(200);
			stext.setTextHeight(40);
			stext.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			stext.text.text = "Schedule";
			addChild(stext);
		}
		
		if (project != null) {
			psubtaskBtn = new BoxButton(state, "Edit Subtasks and Deadlines");
			psubtaskBtn.transformMode = AtlasTransformMode.LOCAL;
			psubtaskBtn.colorTheme = 2;
			psubtaskBtn.pos.copyXY(0, 250);
			addChild(psubtaskBtn);
		}
	}
	
	public override function customUpdate():Void
	{
		if (!noBtn){
			if (backBtn.released) {
				if (task.name != name_box.text.text || task.note != note_box.text.text) {
					d_saveChanges(task, name_box.text.text, note_box.text.text);
				}
				else FullState.current.showMainMenu();
				remove();
				return;
			}
			if (deleteBtn.released) {
				d_delete(task);
				remove();
				return;
			}
		}
		else {
			if (task.name != name_box.text.text || task.note != note_box.text.text) {
				backBtn.visible = true;
				if (backBtn.released) {
					MainScreen.deleteTask(task, true);
					task.name = name_box.text.text;
					task.note = note_box.text.text;
					MainScreen.saveData();
					FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
				}
			}
			else {
				backBtn.visible = false;
			}
		}
		if (editType.released) {
			if (FullState.current.mainMenu != null) FullState.current.mainMenu.remove();
			FullState.current.showTaskList(false, task);
			remove();
			return;
		}
		if (schedule != null) {
			if (sdeleteBtn.released) {
				d_sdelete(task, schedule);
				remove();
				return;
			}
			if (schedule.numOfTimes != 1) {
				if (scancelBtn.released){
					d_scancel(task, schedule);
					remove();
					return;
				}
				else if (sendBtn.released) {
					d_send(task, schedule);
					remove();
					return;
				}
			}
			else if (schedule.isAuto && scancelBtn.released) {
				schedule.isAuto = false;
				scancelBtn.remove();
				scancelBtn = null;
				FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
				MainScreen.saveData();
			}
		}
		if (project != null) {
			if (psubtaskBtn.released) {
				if (FullState.current.mainMenu != null) FullState.current.mainMenu.remove();
				FullState.current.showProjectMenu(cast task);
				remove();
				return;
			}
		}
		else {
			if (editGoal.released) {
				if (FullState.current.mainMenu != null) FullState.current.mainMenu.remove();
				d_editGoalType(task);
				remove();
				return;
			}
		}
		//dont forget to save after edit
	}
	
	public static var dTask:Task;
	public static var dSchedule:Schedule;
	public static function d_delete(task:Task):Void
	{
		dTask = task;
		FullState.current.showDialog(DialogType.SELECT, "Are you sure you want to delete task [" + task.name + "]?", ["Yes"], d_delete2);
	}
	public static function d_delete2(a, b):Void
	{
		FullState.current.showDialog(DialogType.SELECT, "Are you sure? The changes are permanent.", ["Yes"], d_deleteComplete);
	}
	public static function d_deleteComplete(a, b):Void
	{
		MainScreen.deleteTask(dTask);
		FullState.current.showDialog(DialogType.SELECT, "Task [" + dTask.name + "] is now deleted.", ["Okay."], "exit", true);
		dTask = null;
	}
	
	public static function d_sdelete(task:Task, schedule:Schedule):Void
	{
		dTask = task;
		dSchedule = schedule;
		var addStr:String = dSchedule.numOfTimes == 1 ? "" : " and all it's recurrences";
		FullState.current.showDialog(DialogType.SELECT, "Are you sure you want to delete this schedule" + addStr + "?", ["Yes"], d_sdeleteComplete);
	}
	public static function d_sdeleteComplete(a, b):Void
	{
		dTask.schedules.remove(dSchedule);
		FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
		MainScreen.saveData();
		FullState.current.showDialog(DialogType.SELECT, "The schedule is now deleted.", ["Okay."], "exit", true);
		dTask = null;
		dSchedule = null;
	}
	
	public static function d_scancel(task:Task, schedule:Schedule):Void
	{
		dTask = task;
		dSchedule = schedule;
		FullState.current.showDialog(DialogType.SELECT, "Are you sure you want to cancel this schedule for this day?", ["Yes"], d_scancelComplete);
	}
	public static function d_scancelComplete(a, b):Void
	{
		dSchedule.canceled.push(new Date(FullState.current.activeDay.getFullYear(), FullState.current.activeDay.getMonth(), FullState.current.activeDay.getDate(), 0, 0, 0).getTime());
		FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
		MainScreen.saveData();
		FullState.current.showDialog(DialogType.SELECT, "The schedule is now canceled for this day.", ["Okay."], "exit", true);
		dTask = null;
		dSchedule = null;
	}
	
	public static function d_send(task:Task, schedule:Schedule):Void
	{
		dTask = task;
		dSchedule = schedule;
		FullState.current.showDialog(DialogType.SELECT, "End the schedule repeat from this day on?", ["Yes"], d_sendComplete);
	}
	public static function d_sendComplete(a, b):Void
	{
		dSchedule.end = new Date(FullState.current.activeDay.getFullYear(), FullState.current.activeDay.getMonth(), FullState.current.activeDay.getDate()-1, 0, 0, 0);
		FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
		MainScreen.saveData();
		FullState.current.showDialog(DialogType.SELECT, "The schedule will stop repeating from this day on.", ["Okay."], "exit", true);
		dTask = null;
		dSchedule = null;
	}
	
	public static var changedTask:Task;
	public static var changedName:String;
	public static var changedNote:String;
	public static function d_saveChanges(task:Task, newName:String, newNote:String):Void
	{
		changedTask = task;
		changedName = newName;
		changedNote = newNote;
		FullState.current.showDialog(DialogType.SELECT, "Do you want to save the changes?", ["Yes", "No"], d_saveChangesSel, true);
	}
	public static function d_saveChangesSel(a,sel:Int):Void
	{
		if (sel == 0) {
			MainScreen.deleteTask(changedTask, true);
			changedTask.name = changedName;
			changedTask.note = changedNote;
			MainScreen.saveData();
			FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
			FullState.current.showMainMenu();
		}
		else {
			FullState.current.showMainMenu();
		}
	}
	
	public static function d_editGoalType(task:Task):Void
	{
		changedTask = task;
		FullState.current.showDialog(DialogType.SELECT, "What do you want to do for the daily goal of [" + task.name + "]?", ["Clear Goal", "Set Goal", "Back"], d_editGoalDetail, true);
	}
	public static function d_editGoalDetail(options:Array<Dynamic>, selected:Int):Void
	{
		switch (selected){
			case 0:
				changedTask.goalType = "none";
				changedTask.goal = 0;
				MainScreen.saveData();
				FullState.current.showDialog(DialogType.SELECT, "Goal successfully cleared.", ["Okay."], d_editGoalDone, true);
			case 1:
				d_editGoal();
			case 2:
				d_editGoalDone();
		}
	}
	public static function d_editGoal():Void
	{
		FullState.current.showDialog(DialogType.TEXT, "Enter the amount of time you need to complete daily, in minutes.", [], d_editGoalCheck);
	}
	public static function d_editGoalCheck(min:String):Void
	{
		if (!goalRestriction.match(min) && Convert.int(min) > 0) {
			changedTask.goalType = "repeat";
			changedTask.goal = Convert.int(min);
			MainScreen.saveData();
			FullState.current.showDialog(DialogType.SELECT, "Goal successfully set.", ["Okay."], d_editGoalDone, true);
		}
		else {
			FullState.current.showDialog(DialogType.TEXT, "Invalid amount. Please reenter the amount of time you need to complete, in minutes.", [], d_editGoalCheck);
		}
	}
	public static function d_editGoalDone():Void
	{
		FullState.current.showTaskMenu(null, changedTask);
	}
}