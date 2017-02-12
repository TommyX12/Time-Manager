package objects;

import engine.objects.AtlasEntity;
import objects.primitive.UIButton;
import objects.primitive.UIContainer;
import objects.primitive.UIText;
import objects.primitive.UITitle;
import states.State;
import engine.utils.*;
import openfl.text.TextFormat;
import objects.info.*;
import openfl.text.TextFormatAlign;
import screens.MainScreen;
import objects.BoxButton;
import engine.display.AtlasTransformMode;
import states.FullState;

/**
 * ...
 * @author TommyX
 */
class TaskList extends UIContainer
{
	
	public var rowCount:Int = 10;
	public static var goalRestriction:EReg = new EReg("[^0-9]", "i");
	public var page:Int;
	public var _page:Int;
	
	public var add:Bool;
	
	public var title:UITitle;
	
	public var _step:Int;
	public var selectedTypeName:String;
	public var selectedTypeColor:Int;
	public var selectedTasks:Array<Task>;
	
	public var backBtn:BoxButton;
	
	public var pageUpBtn:UIButton;
	public var pageDnBtn:UIButton;
	public var pageTxt:UIText;
	
	public var boxBtns:Array<BoxButton>;
	public var editBtns:Array<BoxButton>;
	
	public var edit4Task:Task;

	public function new(state:State, add:Bool, edit4Task:Task = null) 
	{
		super(state);
		
		this.edit4Task = edit4Task;
		
		page = 0;
		boxBtns = new Array<BoxButton>();
		editBtns = new Array<BoxButton>();
		
		this.add = add;
		
		_step = 0;
		
		title = new UITitle(state);
		title.transformMode = AtlasTransformMode.LOCAL;
		title.pos.copyXY(0, -451);
		title.setTextWidth(600);
		addChild(title);
		
		for (i in 0...rowCount) {
			var btn:BoxButton = new BoxButton(state, "0");
			btn.transformMode = AtlasTransformMode.LOCAL;
			btn.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.LEFT);
			btn.colorTheme = 0;
			btn.width = 600;
			btn.height = 60;
			btn.setTextWidth(580);
			btn.setTextHeight(50);
			btn.visible = false;
			btn.pos.copyXY(0, i*74 - 300);
			boxBtns.push(btn);
			addChild(btn);
			
			var edit:BoxButton = new BoxButton(state, "Edit");
			edit.transformMode = AtlasTransformMode.LOCAL;
			edit.colorTheme = 1;
			edit.visible = false;
			edit.pos.copyXY(-380, i*74 - 300);
			editBtns.push(edit);
			addChild(edit);
		}
		
		backBtn = new BoxButton(state, "Back");
		backBtn.transformMode = AtlasTransformMode.LOCAL;
		backBtn.colorTheme = 1;
		backBtn.pos.copyXY(0, 450);
		addChild(backBtn);
		
		pageUpBtn = new UIButton(state, "_arrow");
		pageUpBtn.transformMode = AtlasTransformMode.LOCAL;
		pageUpBtn.colorTheme = 1;
		pageUpBtn.pos.copyXY(400, -60);
		pageUpBtn.rotation = -90;
		addChild(pageUpBtn);
		
		pageDnBtn = new UIButton(state, "_arrow");
		pageDnBtn.transformMode = AtlasTransformMode.LOCAL;
		pageDnBtn.colorTheme = 1;
		pageDnBtn.pos.copyXY(400, 60);
		pageDnBtn.rotation = 90;
		addChild(pageDnBtn);
		
		pageUpBtn.scale = pageDnBtn.scale = 0.4;
		
		pageTxt = new UIText(state);
		pageTxt.transformMode = AtlasTransformMode.LOCAL;
		pageTxt.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
		pageTxt.pos.copyXY(400, 0);
		pageTxt.setTextWidth(200);
		pageTxt.setTextHeight(50);
		pageTxt.text.textColor = 0x000000;
		pageTxt.text.multiline = false;
		pageTxt.text.wordWrap = false;
		pageTxt.text.text = "";
		addChild(pageTxt);
		
		refreshBtn();
	}
	
	public function refreshBtn():Void
	{
		if (_step == 0) {
			pageTxt.text.text = Convert.string(page+1)+"/"+Convert.string(Math.ceil((MainScreen.data_tasktypes_name.length + 1)/rowCount));
			for (i in 0...rowCount) {
				var j:Int = page * rowCount + i;
				var btn:BoxButton = boxBtns[i];
				if (j >= MainScreen.data_tasktypes_name.length + 1) {
					btn.visible = false;
					editBtns[i].visible = false;
				}
				else {
					if (j == 0) {
						btn.visible = true;
						editBtns[i].visible = false;
						btn.tile = "_gradient";
						btn.color = 0x888888;
						btn.text.text = "+ New Task Type";
					}
					else {
						btn.visible = true;
						editBtns[i].visible = true;
						btn.tile = "_block";
						btn.color = MainScreen.data_tasktypes_color[j-1];
						btn.text.text = MainScreen.data_tasktypes_name[j - 1];
						btn.r *= 0.75;
						btn.g *= 0.75;
						btn.b *= 0.75;
					}
				}
			}
		}
		else if (_step == 1) {
			pageTxt.text.text = Convert.string(page+1)+"/"+Convert.string(Math.ceil((selectedTasks.length + 2)/rowCount));
			for (i in 0...rowCount) {
				var j:Int = page * rowCount + i;
				var btn:BoxButton = boxBtns[i];
				editBtns[i].visible = false;
				if (j >= selectedTasks.length + 2) btn.visible = false;
				else {
					if (j == 0) {
						btn.visible = true;
						btn.tile = "_gradient";
						btn.color = 0x888888;
						btn.text.text = "+ New Task";
					}
					else if (j == 1) {
						btn.visible = true;
						btn.tile = "_gradient";
						btn.color = 0x888888;
						btn.text.text = "+ New Project";
					}
					else {
						btn.visible = true;
						btn.tile = "_block";
						btn.color = MainScreen.data_tasktypes_color[MainScreen.data_tasktypes_name.indexOf(selectedTasks[j-2].type)];
						btn.text.text = selectedTasks[j - 2].name;
						btn.r *= 0.75;
						btn.g *= 0.75;
						btn.b *= 0.75;
					}
				}
			}
		}
	}
	
	public function changePage(delta:Float):Void
	{
		page += Convert.int(delta);
		if (_step == 0) page = Convert.int(Math.min(Math.max(page, 0), Math.ceil((MainScreen.data_tasktypes_name.length + 1) / rowCount) - 1));
		else if (_step == 1) page = Convert.int(Math.min(Math.max(page, 0), Math.ceil((selectedTasks.length + 2) / rowCount)-1));
		refreshBtn();
	}
	
	public override function customUpdate():Void
	{
		title.text.textColor = MainScreen.current.scheme1Color;
		if (pageUpBtn.released) changePage( -1);
		if (pageDnBtn.released) changePage( 1);
		if (Input.mouseWheel != 0) changePage(-Input.mouseWheel);
		if (_step == 0) {
			title.text.text = "Task Types";
			for (i in 0...rowCount) {
				var j:Int = page * rowCount + i;
				var btn:BoxButton = boxBtns[i];
				if (j < MainScreen.data_tasktypes_name.length + 1) {
					if (j == 0) {
						if (btn.released) {
							d_newTaskType(add);
							remove();
							break;
						}
					}
					else {
						if (btn.released) {
							if (edit4Task == null){
								_step++;
								_page = page;
								page = 0;
								selectedTypeName = MainScreen.data_tasktypes_name[j-1];
								selectedTypeColor = MainScreen.data_tasktypes_color[j-1];
								selectedTasks = [];
								for (task in MainScreen.data_tasks) {
									if (task.type == selectedTypeName) {
										selectedTasks.push(task);
									}
								}
								refreshBtn();
								break;
							}
							else {
								edit4Task.type = MainScreen.data_tasktypes_name[j - 1];
								MainScreen.saveData();
								FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
								FullState.current.showTaskMenu(null, edit4Task);
								remove();
								return;
							}
						}
						else if (editBtns[i].released) {
							d_editTaskType(j - 1, edit4Task);
							remove();
							break;
						}
					}
				}
			}
			if (backBtn.released) {
				if (edit4Task == null) FullState.current.showMainMenu();
				else FullState.current.showTaskMenu(null, edit4Task);
				remove();
			}
		}
		else if (_step == 1) {
			title.text.text = selectedTypeName;
			for (i in 0...rowCount) {
				var j:Int = page * rowCount + i;
				var btn:BoxButton = boxBtns[i];
				if (j < selectedTasks.length + 2) {
					if (j == 0) {
						if (btn.released) {
							d_newTask(selectedTypeName, add);
							remove();
							break;
						}
					}
					else if (j == 1) {
						if (btn.released) {
							d_newProject(selectedTypeName);
							remove();
							break;
						}
					}
					else {
						if (btn.released) {
							if (add) {
								d_newSchedule(selectedTasks[j-2]);
							}
							else {
								FullState.current.showTaskMenu(null, selectedTasks[j-2]);
							}
							remove();
							break;
						}
					}
				}
			}
			if (backBtn.released) {
				_step--;
				page = _page;
				refreshBtn();
			}
		}
	}
	
	public static var newTaskTypeName:String;
	public static var newAdd:Bool;
	public static function d_newTaskType(add:Bool):Void
	{
		newAdd = add;
		FullState.current.showDialog(DialogType.TEXT, "Hey there. What is the name of the new task type?", [MainScreen.TASK_NAME_MAXCHARS], d_newTaskTypeColor);
	}
	public static function d_newTaskTypeColor(name:String):Void
	{
		if (MainScreen.data_tasktypes_name.indexOf(name) == -1){
			newTaskTypeName = name;
			FullState.current.showDialog(DialogType.COLOR, "What color will the type [" + name + "] have?", null, d_newTaskTypeComplete);
		}
		else {
			FullState.current.showDialog(DialogType.TEXT, "The name [" + name + "] has been used. Please choose another one.", [MainScreen.TASK_NAME_MAXCHARS], d_newTaskTypeColor);
		}
	}
	public static function d_newTaskTypeComplete(color:Int):Void
	{
		MainScreen.data_tasktypes_name.push(newTaskTypeName);
		MainScreen.data_tasktypes_color.push(color);
		MainScreen.saveData();
		FullState.current.showDialog(DialogType.SELECT, "[" + newTaskTypeName + "] \n task type setup is complete.", ["Okay."], d_newTaskTypeMenu, true);
	}
	public static function d_newTaskTypeMenu(a,b):Void
	{
		FullState.current.showTaskList(newAdd);
	}
	
	public static var newTask:Array<Task>;
	public static function d_newTask(type:String, add:Bool):Void
	{
		newAdd = add;
		newTask = [new Task()];
		newTask[0].type = type;
		FullState.current.showDialog(DialogType.TEXT, "Hey there. What is the name of the new task?", [MainScreen.TASK_NAME_MAXCHARS], d_newTaskNote);
	}
	public static function d_newTaskNote(name:String):Void
	{
		var nameL:String = name.toLowerCase();
		var found:Bool = false;
		for (task in MainScreen.data_tasks) {
			if (task.name.toLowerCase() == nameL) {
				found = true;
				break;
			}
		}
		if (found) {
			FullState.current.showDialog(DialogType.TEXT, "The name [" + nameL + "] has been used. Please choose another one.", [MainScreen.TASK_NAME_MAXCHARS], d_newTaskNote);
		}
		else {
			newTask[0].name = name;
			FullState.current.showDialog(DialogType.LONGTEXT, "Any note for the task [" + name + "]?", [MainScreen.TASK_NOTE_MAXCHARS], d_newTaskGoalType);
		}
	}
	public static function d_newTaskGoalType(note:String):Void
	{
		newTask[0].note = note;
		FullState.current.showDialog(DialogType.SELECT, "Is there a daily goal for this task?", ["No", "Yes"], d_newTaskGoalDetail);
	}
	public static function d_newTaskGoalDetail(options:Array<Dynamic>, selected:Int):Void
	{
		switch (selected){
			case 0:
				newTask[0].goalType = "none";
				d_newTaskComplete();
			case 1:
				newTask[0].goalType = "repeat";
				d_newTaskGoal();
		}
	}
	public static function d_newTaskGoal():Void
	{
		FullState.current.showDialog(DialogType.TEXT, "Enter the amount of time you need to complete, in minutes.", [], d_newTaskGoalCheck);
	}
	public static function d_newTaskGoalCheck(min:String):Void
	{
		if (!goalRestriction.match(min) && Convert.int(min) > 0) {
			newTask[0].goal = Convert.int(min);
			d_newTaskComplete();
		}
		else {
			FullState.current.showDialog(DialogType.TEXT, "Invalid amount. Please reenter the amount of time you need to complete, in minutes.", [], d_newTaskGoalCheck);
		}
	}
	public static function d_newTaskComplete():Void
	{
		MainScreen.data_tasks.push(newTask[0]);
		MainScreen.saveData();
		FullState.current.showDialog(DialogType.SELECT, "[" + newTask[0].name + "] \n task setup is complete.", ["Okay."], d_newTaskMenu, true);
	}
	public static function d_newTaskMenu(a,b):Void
	{
		if (newAdd) {
			d_newSchedule(newTask[0]);
		}
		else FullState.current.showMainMenu();
	}
	
	public static var newSchedule:Array<Schedule>;
	public static var newScheduleTask:Task;
	public static function d_newSchedule(task:Task):Void
	{
		newSchedule = [new Schedule()];
		newScheduleTask = task;
		FullState.current.newSchedule = 2;
		FullState.current.newScheduleSM = FullState.current.newScheduleEM = 0;
		FullState.current.newScheduleM.setTask(task);
		FullState.current.showDialog(DialogType.SELECT, "Hey there. Please click and drag on the timeline to create a new schedule for [" + task.name + "].", ["Confirm", "Cancel"], d_newScheduleConfirm, true);
	}
	public static function d_newScheduleCancel():Void
	{
		FullState.current.newSchedule = 0;
		FullState.current.showMainMenu();
	}
	public static function d_newScheduleConfirm(options, selection:Int):Void
	{
		if (selection == 1) d_newScheduleCancel();
		//else check conflick, also if schedule is visible and length valid.
		else {
			if (Math.abs(FullState.current.newScheduleEM - FullState.current.newScheduleSM) >= 5) {
				if (FullState.current.newScheduleSM < FullState.current.newScheduleEM) {
					newSchedule[0].startMinute = FullState.current.newScheduleSM;
					newSchedule[0].endMinute = FullState.current.newScheduleEM;
				}
				else {
					newSchedule[0].startMinute = FullState.current.newScheduleEM;
					newSchedule[0].endMinute = FullState.current.newScheduleSM;
				}
				newSchedule[0].start = Date.fromString(FullState.current.activeDay.toString());
				FullState.current.newSchedule = 1;
				FullState.current.showDialog(DialogType.SELECT, "Does this schedule repeat regularly?", ["Yes", "No", "Cancel"], d_newScheduleRepeat, true);
			}
			else {
				FullState.current.showDialog(DialogType.SELECT, "The length of the schedule is too short. Please retry.", ["Confirm", "Cancel"], d_newScheduleConfirm, true);
			}
		}
	}
	public static function d_newScheduleRepeat(options, selection:Int):Void
	{
		if (selection == 2) d_newScheduleCancel();
		//else check conflick, also if schedule is visible and length valid.
		else if (selection == 0){
			newSchedule[0].numOfTimes = 0;
			FullState.current.showDialog(DialogType.TIME, "How often does it repeat?", [4], d_newScheduleRepeatLength, true);
		}
		else if (selection == 1){
			newSchedule[0].numOfTimes = 1;
			d_newScheduleComplete();
		}
	}
	public static function d_newScheduleRepeatLength(period:Int, unit:String):Void
	{
		newSchedule[0].repeatPeriod = period;
		newSchedule[0].repeatUnit = unit;
		FullState.current.showDialog(DialogType.SELECT, "Does the repeat end at any time?", ["Yes", "No", "Cancel"], d_newScheduleEnd, true);
	}
	public static function d_newScheduleEnd(options, selection:Int):Void
	{
		if (selection == 2) d_newScheduleCancel();
		//else check conflick, also if schedule is visible and length valid.
		else if (selection == 0){
			FullState.current.showDialog(DialogType.DATE, "Please enter the ending date(inclusive).", [], d_newScheduleEndDate, true);
		}
		else if (selection == 1){
			newSchedule[0].end = null;
			d_newScheduleComplete();
		}
	}
	public static function d_newScheduleEndDate(y:Int, m:Int, d:Int):Void
	{
		newSchedule[0].end = new Date(y, m-1, d, 0,0,0);
		d_newScheduleComplete();
	}
	public static function d_newScheduleComplete():Void
	{
		FullState.current.newSchedule = 0;
		newScheduleTask.schedules.push(newSchedule[0]);
		FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
		FullState.current.checkConflict = true;
		MainScreen.saveData();
		FullState.current.showDialog(DialogType.SELECT, "Schedule setup is complete.", ["Okay."], "exit", true);
	}
	
	public static var newProject:Array<Project>;
	public static function d_newProject(type:String):Void
	{
		newProject = [new Project()];
		newProject[0].type = type;
		FullState.current.showDialog(DialogType.TEXT, "Hey there. What is the name of the new project?", [MainScreen.TASK_NAME_MAXCHARS], d_newProjectNote);
	}
	public static function d_newProjectNote(name:String):Void
	{
		var nameL:String = name.toLowerCase();
		var found:Bool = false;
		for (task in MainScreen.data_tasks) {
			if (task.name.toLowerCase() == nameL) {
				found = true;
				break;
			}
		}
		if (found) {
			FullState.current.showDialog(DialogType.TEXT, "The name [" + nameL + "] has been used. Please choose another one.", [MainScreen.TASK_NAME_MAXCHARS], d_newProjectNote);
		}
		else {
			newProject[0].name = name;
			FullState.current.showDialog(DialogType.LONGTEXT, "Any note for the project [" + name + "]?", [MainScreen.TASK_NOTE_MAXCHARS], d_newProjectComplete);
		}
	}
	public static function d_newProjectComplete(note:String):Void
	{
		newProject[0].note = note;
		MainScreen.data_tasks.push(newProject[0]);
		MainScreen.saveData();
		FullState.current.showDialog(DialogType.SELECT, "[" + newProject[0].name + "] \n project setup is complete. Please proceed to edit subtasks and deadlines for this project.", ["Okay."], d_newProjectMenu, true);
	}
	public static function d_newProjectMenu(a,b):Void
	{
		FullState.current.showTaskMenu(null, newProject[0]);
	}
	
	public static var editTaskType:Int;
	public static var edit4Taskkk:Task;
	public static function d_editTaskType(taskType:Int, edit4Task:Task):Void
	{
		editTaskType = taskType;
		edit4Taskkk = edit4Task;
		FullState.current.showDialog(DialogType.SELECT, "What would you like to do with the task type [" + MainScreen.data_tasktypes_name[editTaskType] + "]?", ["Edit Name", "Edit Color", "Delete", "Cancel"], d_editTaskTypeSel, true);
	}
	public static function d_editTaskTypeSel(a, sel:Int):Void
	{
		if (sel == 0) {
			FullState.current.showDialog(DialogType.TEXT, "What is the new name of the task type ["+ MainScreen.data_tasktypes_name[editTaskType] +"]?", [MainScreen.TASK_NAME_MAXCHARS, MainScreen.data_tasktypes_name[editTaskType]], d_editTaskTypeName);
		}
		else if (sel == 1) {
			FullState.current.showDialog(DialogType.COLOR, "What is the new color of the task type ["+ MainScreen.data_tasktypes_name[editTaskType] +"]?", null, d_editTaskTypeColor);
		}
		else if (sel == 2){
			FullState.current.showDialog(DialogType.SELECT, "Are you sure? All tasks and schedules under this type will also be deleted.", ["Yes"], d_editTaskTypeDelPre);
		}
		else d_editTaskTypeDone(0,0);
	}
	public static function d_editTaskTypeDelPre(a,b):Void
	{
		FullState.current.showDialog(DialogType.SELECT, "Are you really sure? The changes are permanent.", ["Yes"], d_editTaskTypeDelPre2);
	}
	public static function d_editTaskTypeDelPre2(a,b):Void
	{
		FullState.current.showDialog(DialogType.SELECT, "Last Chance.", ["I said yes"], d_editTaskTypeDel);
	}
	public static function d_editTaskTypeDel(a,b):Void
	{
		var oldName:String = MainScreen.data_tasktypes_name[editTaskType];
		MainScreen.data_tasktypes_name.splice(editTaskType, 1);
		MainScreen.data_tasktypes_color.splice(editTaskType, 1);
		for (task in MainScreen.data_tasks) {
			if (task.type == oldName) {
				MainScreen.deleteTask(task);
			}
		}
		MainScreen.saveData();
		FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
		FullState.current.showDialog(DialogType.SELECT, "The task type [" + oldName + "] and it's tasks are now deleted.", ["Okay."], d_editTaskTypeDone, true);
	}
	public static function d_editTaskTypeName(text:String):Void
	{
		var oldName:String = MainScreen.data_tasktypes_name[editTaskType];
		MainScreen.data_tasktypes_name[editTaskType] = text;
		for (task in MainScreen.data_tasks) {
			if (task.type == oldName) task.type = text;
		}
		MainScreen.saveData();
		FullState.current.showDialog(DialogType.SELECT, "The task type [" + oldName + "] is now renamed into [" + text + "].", ["Okay."], d_editTaskTypeDone, true);
	}
	public static function d_editTaskTypeColor(color:Int):Void
	{
		MainScreen.data_tasktypes_color[editTaskType] = color;
		MainScreen.saveData();
		FullState.current.timeLine.refreshMarkers(FullState.current.activeDay);
		FullState.current.showDialog(DialogType.SELECT, "The task type's color is now updated.", ["Okay."], d_editTaskTypeDone, true);
	}
	public static function d_editTaskTypeDone(a,b):Void
	{
		FullState.current.showTaskList(false, edit4Taskkk);
	}
	
}