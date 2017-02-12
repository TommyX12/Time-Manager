package objects;

import engine.display.AtlasDisplay;
import engine.objects.AtlasContainer;
import engine.objects.AtlasEntity;
import engine.display.AtlasTransformMode;
import engine.utils.Grid;
import objects.info.*;
import objects.primitive.UIContainer;
import openfl.text.*;
import objects.primitive.UIText;
import objects.primitive.UITextbox;
import screens.MainScreen;
import states.State;
import states.FullState;
import engine.utils.*;
import objects.primitive.UIButton;
import engine.NRFDisplay;

/**
 * ...
 * @author TommyX
 */
class ProjectMenu extends UIContainer
{
	
	public static var spacing:Float = 15+60;
	public static var scrolling:Float = 20;
	
	public static var numRestriction:EReg = new EReg("[^0-9:]", "i");
	public static var dateRestriction:EReg = new EReg("[^0-9/]", "i");
	
	public var project:Project;
	
	public var confirmBtn:BoxButton;
	
	public var editing:Int;
	public var addSubTaskBtn:BoxButton;
	public var addDeadlineBtn:BoxButton;
	public var interactBtn:BoxButton;
	
	public var a:Dynamic;
	public var b:Dynamic;
	
	public var tempBlock:UIButton;
	public var insertPos:Int;
	public var interactPos:Int;
	
	public var oldBtnPos:Vec2D;
	
	public var subtasks:Array<UIButton>;
	
	public var length:Float;
	
	public var yDest:Float;
	
	public var draggingOffset:Vec2D;

	public function new(state:State, project:Project) 
	{
		super(state);
		
		this.project = project;
		
		oldBtnPos = new Vec2D();
		
		editing = 0;
		insertPos = 0;
		interactPos = 0;
		
		confirmBtn = new BoxButton(state, "Back");
		confirmBtn.transformMode = AtlasTransformMode.LOCAL;
		confirmBtn.colorTheme = 2;
		confirmBtn.pos.x = -400;
		addChild(confirmBtn);
		
		addSubTaskBtn = new BoxButton(state, "Add SubTask");
		addSubTaskBtn.transformMode = AtlasTransformMode.LOCAL;
		addSubTaskBtn.colorTheme = 2;
		addSubTaskBtn.pos.x = -180;
		addSubTaskBtn.pos.y = -(spacing + 60) / 2;
		addChild(addSubTaskBtn);
		
		addDeadlineBtn = new BoxButton(state, "Add Deadline");
		addDeadlineBtn.transformMode = AtlasTransformMode.LOCAL;
		addDeadlineBtn.colorTheme = 2;
		addDeadlineBtn.pos.x = 80;
		addDeadlineBtn.pos.y = -(spacing + 60) / 2;
		addChild(addDeadlineBtn);
		
		interactBtn = new BoxButton(state, "Delete");
		interactBtn.transformMode = AtlasTransformMode.LOCAL;
		interactBtn.colorTheme = 2;
		interactBtn.pos.x = 285;
		interactBtn.pos.y = 0;
		addChild(interactBtn);
		
		subtasks = [];
		for (i in 0...Convert.int(project.subtasks.length / 2)) {
			var j:Int = i * 2;
			var btn:UIButton = newBtn(project.subtasks[j], project.subtasks[j + 1]);
			addChild(btn);
			subtasks.push(btn);
		}
		reposition();
		
		yDest = NRFDisplay.centerHeight;
		
		draggingOffset = new Vec2D();
	}
	
	public function newBtn(a:Dynamic, b:Dynamic):UIButton
	{
		var btn:UIButton = new UIButton(state, "_block");
		btn.transformMode = AtlasTransformMode.LOCAL;
		btn.colorTheme = 0;
		btn.width = 500;
		btn.height = 60;
		btn.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.LEFT);
		btn.text.multiline = false;
		btn.text.wordWrap = false;
		btn.setTextWidth(480);
		btn.setTextHeight(50);
		btn.buttonEnabled = true;
		if (a == -1) {
			btn.tile = "_gradient";
			btn.text.appendText("Deadline\t");
			btn.text.appendText(Util.getFileNameNumber(b.getFullYear(), 4)+"/"+Util.getFileNameNumber(b.getMonth()+1, 2)+"/"+Util.getFileNameNumber(b.getDate(), 2));
			btn.color = 0x888888;
		}
		else {
			var h:Int = Math.floor(a / 60);
			var m:Int = Math.floor(a - 60 * h);
			btn.text.appendText(Convert.string(h) + "h" + Convert.string(m) + "min\t");
			btn.text.appendText(b);
			btn.color = MainScreen.data_tasktypes_color[MainScreen.data_tasktypes_name.indexOf(project.type)];
			btn.r *= 0.75;
			btn.g *= 0.75;
			btn.b *= 0.75;
		}
		return btn;
	}
	
	public function reposition():Void
	{
		length = 0;
		for (i in 0...subtasks.length) {
			var btn:UIButton = subtasks[i];
			btn.pos.copyXY(-50, i * (60 + spacing));
			length += 60 + spacing;
		}
		if (length > 0) length -= 60 + spacing;
	}
	
	public override function customUpdate():Void
	{
		if (Input.mousePos.y < 100) yDest += scrolling;
		else if (Input.mousePos.y > NRFDisplay.rawHeight - 100) yDest -= scrolling;
		yDest += Input.mouseWheel*scrolling*3;
		yDest = Math.min(Math.max(yDest, NRFDisplay.centerHeight - length), NRFDisplay.centerHeight);
		this.pos.y += (yDest - this.pos.y) * 0.5;
		
		confirmBtn.pos.y = NRFDisplay.centerHeight - this.pos.y;
		if (confirmBtn.released){
			MainScreen.saveData();
			FullState.current.showTaskMenu(null, project);
			remove();
			return;
		}
		if (editing == 0) {
			if (subtasks[0] != null){
				insertPos = Math.ceil(Math.min(Math.max((Input.mousePos.y - this.pos.y), -(spacing + 60) * 0.5), length + (spacing + 60) * 0.5) / (spacing + 60));
				interactPos = Math.floor((Math.min(Math.max((Input.mousePos.y - this.pos.y), 0), length)+ (spacing + 60) * 0.5) / (spacing + 60));
				addDeadlineBtn.pos.y = addSubTaskBtn.pos.y = insertPos * (spacing + 60) - (spacing + 60) * 0.5;
				interactBtn.pos.y = interactPos * (spacing + 60);
				interactBtn.visible = true;
			}
			else {
				insertPos = 0;
				interactPos = 0;
				addDeadlineBtn.pos.y = addSubTaskBtn.pos.y = 0;
				interactBtn.visible = false;
			}
			for (i in 0...subtasks.length) {
				var btn:UIButton = subtasks[i];
				if (btn.pressed) {
					oldBtnPos.copy(btn.pos);
					draggingOffset = Input.mousePos.sub(this.pos).sub(btn.pos);
					addSubTaskBtn.visible = false;
					addDeadlineBtn.visible = false;
					break;
				}
				if (btn.down) {
					btn.pos.copyXY(Input.mousePos.x - this.pos.x - draggingOffset.x, Input.mousePos.y - this.pos.y - draggingOffset.y);
					interactBtn.visible = false;
				}
				if (Input.mouseReleased && btn.down) {
					if (btn.pos.distanceSqr(oldBtnPos) < 25) {
						reposition();
						if (btn.tile == "_block") {
							editing = 4;
							addSubTaskBtn.visible = false;
							addDeadlineBtn.visible = false;
							interactBtn.visible = true;
							interactBtn.text.text = "Done";
							tempBlock = btn;
							tempBlock.text.type = TextFieldType.INPUT;
							tempBlock.text.maxChars = MainScreen.TASK_NAME_MAXCHARS;
							tempBlock.text.selectable = true;
							tempBlock.text.border = true;
							tempBlock.text.borderColor = 0xFFFFFF;
							tempBlock.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
							var str:String = btn.text.text.split("\t")[0].split("h").join(":");
							tempBlock.text.text = str.substr(0, str.length-3);
							break;
						}
						else {
							editing = 5;
							addSubTaskBtn.visible = false;
							addDeadlineBtn.visible = false;
							interactBtn.visible = true;
							interactBtn.text.text = "Done";
							tempBlock = btn;
							tempBlock.text.type = TextFieldType.INPUT;
							tempBlock.text.maxChars = MainScreen.TASK_NAME_MAXCHARS;
							tempBlock.text.selectable = true;
							tempBlock.text.border = true;
							tempBlock.text.borderColor = 0xFFFFFF;
							tempBlock.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
							tempBlock.text.text = btn.text.text.split("\t")[1];
							break;
						}
					}
					else {
						a = project.subtasks[i * 2];
						b = project.subtasks[i * 2 + 1];
						project.subtasks[i * 2] = -2;
						project.subtasks[i * 2 + 1] = -2;
						project.subtasks.insert(insertPos * 2, b);
						project.subtasks.insert(insertPos * 2, a);
						var block:UIButton = newBtn(a, b);
						subtasks[i].remove();
						subtasks[i] = null;
						subtasks.insert(insertPos, block);
						subtasks.remove(null);
						project.subtasks.remove( -2);
						project.subtasks.remove( -2);
						addChild(block);
						reposition();
						addSubTaskBtn.visible = true;
						addDeadlineBtn.visible = true;
						break;
					}
				}
			}
			if (interactBtn.released) {
				project.subtasks.splice(interactPos * 2, 2);
				subtasks[interactPos].remove();
				subtasks.splice(interactPos, 1);
				reposition();
			}
			if (addSubTaskBtn.released) {
				editing = 1;
				addSubTaskBtn.visible = false;
				addDeadlineBtn.visible = false;
				interactBtn.text.text = "Next";
				interactBtn.pos.y = addDeadlineBtn.pos.y;
				interactBtn.visible = true;
				tempBlock = newBtn(1, "new");
				tempBlock.pos.y = addDeadlineBtn.pos.y;
				tempBlock.pos.x = -50;
				tempBlock.colorTheme = 2;
				addChild(tempBlock);
				tempBlock.text.type = TextFieldType.INPUT;
				tempBlock.text.maxChars = MainScreen.TASK_NAME_MAXCHARS;
				tempBlock.text.selectable = true;
				tempBlock.text.border = true;
				tempBlock.text.borderColor = 0xFFFFFF;
				tempBlock.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
				tempBlock.text.text = "Enter subtask name";
			}
			if (addDeadlineBtn.released) {
				editing = 3;
				addSubTaskBtn.visible = false;
				addDeadlineBtn.visible = false;
				interactBtn.text.text = "Done";
				interactBtn.pos.y = addDeadlineBtn.pos.y;
				interactBtn.visible = true;
				tempBlock = newBtn(1, "new");
				tempBlock.pos.y = addDeadlineBtn.pos.y;
				tempBlock.pos.x = -50;
				tempBlock.colorTheme = 2;
				addChild(tempBlock);
				tempBlock.text.type = TextFieldType.INPUT;
				tempBlock.text.maxChars = MainScreen.TASK_NAME_MAXCHARS;
				tempBlock.text.selectable = true;
				tempBlock.text.border = true;
				tempBlock.text.borderColor = 0xFFFFFF;
				tempBlock.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.CENTER);
				tempBlock.text.text = Util.getFileNameNumber(FullState.current.activeDay.getFullYear(), 4)+"/"+Util.getFileNameNumber(FullState.current.activeDay.getMonth()+1, 2)+"/"+Util.getFileNameNumber(FullState.current.activeDay.getDate(), 2);
			}
		}
		else if (editing == 1) {
			if (interactBtn.released || Input.keyPressed(Key.ENTER)) {
				b = tempBlock.text.text;
				editing = 2;
				interactBtn.text.text = "Done";
				tempBlock.text.text = "Enter time needed as HH:MM";
			}
		}
		else if (editing == 2) {
			if ((interactBtn.released || Input.keyPressed(Key.ENTER)) && !numRestriction.match(tempBlock.text.text)) {
				a = 0;
				var hm:Array<String> = tempBlock.text.text.split(":");
				if (hm.length == 1) a = Convert.int(hm[0]);
				else if (hm.length > 1) a = Convert.int(hm[0]) * 60 + Convert.int(hm[1]);
				editing = 0;
				interactBtn.text.text = "Delete";
				tempBlock.remove();
				tempBlock = null;
				addSubTaskBtn.visible = true;
				addDeadlineBtn.visible = true;
				project.subtasks.insert(insertPos * 2, b);
				project.subtasks.insert(insertPos * 2, a);
				var block:UIButton = newBtn(a, b);
				subtasks.insert(insertPos, block);
				addChild(block);
				reposition();
			}
		}
		else if (editing == 3) {
			if ((interactBtn.released || Input.keyPressed(Key.ENTER)) && !dateRestriction.match(tempBlock.text.text)) {
				var date:Array<String> = tempBlock.text.text.split("/");
				if (date.length >= 3) {
					var y:Int = Convert.int(date[0]);
					var m:Int = Convert.int(date[1]);
					var d:Int = Convert.int(date[2]);
					if (y > 1999 && y < 2100 && m > 0 && m < 13 && d > 0 && d <= DateTools.getMonthDays(new Date(y, m - 1, 1, 0, 0, 0))) {
						editing = 0;
						interactBtn.text.text = "Delete";
						tempBlock.remove();
						tempBlock = null;
						addSubTaskBtn.visible = true;
						addDeadlineBtn.visible = true;
						var bb:Date = new Date(y, m - 1, d,0,0,0);
						project.subtasks.insert(insertPos * 2, bb);
						project.subtasks.insert(insertPos * 2, -1);
						var block:UIButton = newBtn(-1, bb);
						subtasks.insert(insertPos, block);
						addChild(block);
						reposition();
					}
				}
			}
		}
		else if (editing == 4) {
			if ((interactBtn.released || Input.keyPressed(Key.ENTER)) && !numRestriction.match(tempBlock.text.text)) {
				a = 0;
				b = project.subtasks[interactPos * 2 + 1];
				var hm:Array<String> = tempBlock.text.text.split(":");
				if (hm.length == 1) a = Convert.int(hm[0]);
				else if (hm.length > 1) a = Convert.int(hm[0]) * 60 + Convert.int(hm[1]);
				editing = 0;
				interactBtn.text.text = "Delete";
				addSubTaskBtn.visible = true;
				addDeadlineBtn.visible = true;
				project.subtasks[interactPos * 2] = a;
				tempBlock.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.LEFT);
				var h:Int = Math.floor(a / 60);
				var m:Int = Math.floor(a - 60 * h);
				tempBlock.text.type = TextFieldType.DYNAMIC;
				tempBlock.text.text = Convert.string(h) + "h" + Convert.string(m) + "min\t";
				tempBlock.text.selectable = false;
				tempBlock.text.border = false;
				tempBlock.text.appendText(b);
				tempBlock = null;
			}
		}
		else if (editing == 5) {
			if ((interactBtn.released || Input.keyPressed(Key.ENTER)) && !dateRestriction.match(tempBlock.text.text)) {
				var date:Array<String> = tempBlock.text.text.split("/");
				if (date.length >= 3) {
					var y:Int = Convert.int(date[0]);
					var m:Int = Convert.int(date[1]);
					var d:Int = Convert.int(date[2]);
					if (y > 1999 && y < 2100 && m > 0 && m < 13 && d > 0 && d <= DateTools.getMonthDays(new Date(y, m - 1, 1, 0, 0, 0))) {
						editing = 0;
						var bb:Date = new Date(y, m - 1, d,0,0,0);
						interactBtn.text.text = "Delete";
						addSubTaskBtn.visible = true;
						addDeadlineBtn.visible = true;
						project.subtasks[interactPos * 2 + 1] = bb;
						tempBlock.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 32, 0xFFFFFF, true, null, null, null, null, TextFormatAlign.LEFT);
						tempBlock.text.type = TextFieldType.DYNAMIC;
						tempBlock.text.text = "Deadline\t";
						tempBlock.text.selectable = false;
						tempBlock.text.border = false;
						tempBlock.text.appendText(Util.getFileNameNumber(bb.getFullYear(), 4)+"/"+Util.getFileNameNumber(bb.getMonth()+1, 2)+"/"+Util.getFileNameNumber(bb.getDate(), 2));
						tempBlock = null;
					}
				}
			}
		}
	}
	
}