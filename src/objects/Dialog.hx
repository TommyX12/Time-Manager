package objects;

import engine.objects.AtlasEntity;
import objects.info.TaskType;
import objects.primitive.UIButton;
import objects.primitive.UIContainer;
import objects.primitive.UIText;
import objects.primitive.UITextbox;
import objects.primitive.UITitle;
import states.State;
import engine.utils.*;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import screens.MainScreen;
import objects.BoxButton;
import engine.display.AtlasTransformMode;
import states.FullState;
import objects.primitive.UIEntity;

/**
 * ...
 * @author TommyX
 */
class Dialog extends UIContainer
{
	
	//other types: LIST
	
	//for date: options[0] allow hours + minutes, options[1] show today btn. check if entered day is valid and is not passed(timestamp).
	//for time: options[0] allow hours + minutes. check if entered time is valid.
	
	public static var colorList:Array<Int> = [
		0xFF4444, 0xFFFF44, 0x44FF44, 0x44FFFF,
		0x4444FF, 0xFF44FF, 0x8844FF, 0x999999
	];
	
	public static var textRestriction:EReg = new EReg("[<>:\"/\\\\\\|\\?\\*]", "i");
	
	public static var timeRestriction:EReg = new EReg("[^0-9]", "i");
	
	public static var timeUnitList:Array<String> = ["day", "week", "month", "year"];
	
	public var prompt:UITitle;
	public var promptText:String;
	public var type:String;
	public var options:Array<Dynamic>;
	public var handler:Dynamic;
	public var noCancel:Bool;
	
	public var list:Array<UIEntity>;
	
	public var backBtn:BoxButton;

	public function new(state:State, type:String, prompt:String, options:Array<Dynamic>, handler:Dynamic, noCancel:Bool) 
	{
		super(state);
		
		this.prompt = new UITitle(state);
		this.prompt.transformMode = AtlasTransformMode.LOCAL;
		this.prompt.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 52, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
		this.prompt.pos.copyXY(0, -250);
		this.prompt.setTextWidth(800);
		this.prompt.setTextHeight(800);
		promptText = prompt;
		this.prompt.text.text = promptText;
		this.prompt.setTextHeight(this.prompt.text.textHeight + 100);
		addChild(this.prompt);
		
		this.type = type;
		this.options = options == null ? null : options.slice(0);
		this.handler = handler;
		this.noCancel = noCancel;
		
		list = [];
		
		if (!noCancel){
			backBtn = new BoxButton(state, "Cancel");
			backBtn.transformMode = AtlasTransformMode.LOCAL;
			backBtn.colorTheme = 2;
			backBtn.pos.copyXY(0, 400);
			addChild(backBtn);
		}
		
		if (type == DialogType.COLOR) {
			for (i in 0...16) {
				var btn:UIButton = new UIButton(state, "_block");
				btn.transformMode = AtlasTransformMode.LOCAL;
				btn.colorTheme = 0;
				btn.width = 80; btn.height = 40;
				var row:Int = Math.floor(i / 4);
				var column:Float = i % 4 - 1.5;
				btn.pos.copyXY(column * 120, row * 60 + 10);
				if (i < 8) btn.color = colorList[i];
				else btn.color = genColor();
				list.push(btn);
				addChild(btn);
			}
			var btn:BoxButton = new BoxButton(state, "Refresh Color");
			btn.transformMode = AtlasTransformMode.LOCAL;
			btn.colorTheme = 2;
			btn.pos.copyXY(0, 275);
			list.push(btn);
			addChild(btn);
		}
		else if (type == DialogType.SELECT) {
			for (i in 0...options.length) {
				var btn:BoxButton = new BoxButton(state, options[i]);
				btn.transformMode = AtlasTransformMode.LOCAL;
				btn.colorTheme = 2;
				var row:Float = i - (options.length-1) / 2;
				btn.pos.copyXY(0, row * 80 + 140);
				list.push(btn);
				addChild(btn);
			}
		}
		else if (type == DialogType.TEXT) {
			var btn:BoxButton = new BoxButton(state, "Confirm");
			btn.transformMode = AtlasTransformMode.LOCAL;
			btn.colorTheme = 2;
			btn.pos.copyXY(0, 80);
			list.push(btn);
			addChild(btn);
			
			var textbox:UITextbox = new UITextbox(state, "_null");
			textbox.transformMode = AtlasTransformMode.LOCAL;
			textbox.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 24, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			textbox.setTextWidth(500);
			textbox.setTextHeight(32);
			textbox.text.multiline = false;
			textbox.text.borderColor = 0x000000;
			textbox.pos.copyXY(0, 0);
			textbox.text.maxChars = options[0];
			if (options[1] != null) textbox.text.text = options[1];
			list.push(textbox);
			addChild(textbox);
		}
		else if (type == DialogType.LONGTEXT) {
			var btn:BoxButton = new BoxButton(state, "Confirm");
			btn.transformMode = AtlasTransformMode.LOCAL;
			btn.colorTheme = 2;
			btn.pos.copyXY(0, 320);
			list.push(btn);
			addChild(btn);
			
			var textbox:UITextbox = new UITextbox(state, "_null");
			textbox.transformMode = AtlasTransformMode.LOCAL;
			textbox.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 20, 0x000000, null, null, null, null, null, TextFormatAlign.LEFT);
			textbox.setTextWidth(500);
			textbox.setTextHeight(300);
			textbox.text.borderColor = 0x000000;
			textbox.pos.copyXY(0, 100);
			textbox.text.maxChars = options[0];
			list.push(textbox);
			addChild(textbox);
		}
		else if (type == DialogType.TIME) {
			var btn:BoxButton = new BoxButton(state, "Confirm");
			btn.transformMode = AtlasTransformMode.LOCAL;
			btn.colorTheme = 2;
			btn.pos.copyXY(0, 225);
			list.push(btn);
			addChild(btn);
			
			var every:UIText = new UIText(state);
			every.transformMode = AtlasTransformMode.LOCAL;
			every.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 24, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			every.setTextWidth(100);
			every.setTextHeight(32);
			every.pos.copyXY(-200, 0);
			every.text.text = "Every";
			addChild(every);
			
			var textbox:UITextbox = new UITextbox(state, "_null");
			textbox.transformMode = AtlasTransformMode.LOCAL;
			textbox.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 24, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			textbox.setTextWidth(100);
			textbox.setTextHeight(32);
			textbox.text.multiline = false;
			textbox.text.borderColor = 0x000000;
			textbox.pos.copyXY(-100, 0);
			textbox.text.maxChars = 4;
			textbox.text.text = "01";
			list.push(textbox);
			addChild(textbox);
			
			var unit:UIText = new UIText(state);
			unit.transformMode = AtlasTransformMode.LOCAL;
			unit.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 24, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			unit.setTextWidth(100);
			unit.setTextHeight(32);
			unit.pos.copyXY(200, 0);
			unit.text.text = "day";
			list.push(unit);
			addChild(unit);
			
			var l:Int = options[0];
			for (i in 0...l ) {
				var btn:BoxButton = new BoxButton(state, timeUnitList[i]);
				btn.transformMode = AtlasTransformMode.LOCAL;
				btn.colorTheme = 2;
				var row:Float = i - (l-1) / 2;
				btn.pos.copyXY(75, row * 80);
				list.push(btn);
				addChild(btn);
			}
		}
		
		else if (type == DialogType.DATE) {
			var btn:BoxButton = new BoxButton(state, "Confirm");
			btn.transformMode = AtlasTransformMode.LOCAL;
			btn.colorTheme = 2;
			btn.pos.copyXY(0, 150);
			list.push(btn);
			addChild(btn);
			
			var year:UITextbox = new UITextbox(state, "_null");
			year.transformMode = AtlasTransformMode.LOCAL;
			year.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 24, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			year.setTextWidth(100);
			year.setTextHeight(32);
			year.text.multiline = false;
			year.text.borderColor = 0x000000;
			year.pos.copyXY(-150, 0);
			year.text.maxChars = 4;
			year.text.text = Convert.string(FullState.current.activeDay.getFullYear());
			list.push(year);
			addChild(year);
			
			var _year:UIText = new UIText(state);
			_year.transformMode = AtlasTransformMode.LOCAL;
			_year.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 24, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			_year.setTextWidth(100);
			_year.setTextHeight(32);
			_year.text.multiline = false;
			_year.pos.copyXY(year.pos.x, -35);
			_year.text.maxChars = 4;
			_year.text.text = "Year";
			addChild(_year);
			
			var month:UITextbox = new UITextbox(state, "_null");
			month.transformMode = AtlasTransformMode.LOCAL;
			month.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 24, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			month.setTextWidth(100);
			month.setTextHeight(32);
			month.text.multiline = false;
			month.text.borderColor = 0x000000;
			month.pos.copyXY(0, 0);
			month.text.maxChars = 2;
			month.text.text = Util.getFileNameNumber(FullState.current.activeDay.getMonth()+1, 2);
			list.push(month);
			addChild(month);
			
			var _month:UIText = new UIText(state);
			_month.transformMode = AtlasTransformMode.LOCAL;
			_month.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 24, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			_month.setTextWidth(100);
			_month.setTextHeight(32);
			_month.text.multiline = false;
			_month.pos.copyXY(month.pos.x, -35);
			_month.text.maxChars = 4;
			_month.text.text = "Month";
			addChild(_month);
			
			var day:UITextbox = new UITextbox(state, "_null");
			day.transformMode = AtlasTransformMode.LOCAL;
			day.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 24, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			day.setTextWidth(100);
			day.setTextHeight(32);
			day.text.multiline = false;
			day.text.borderColor = 0x000000;
			day.pos.copyXY(150, 0);
			day.text.maxChars = 2;
			day.text.text = Util.getFileNameNumber(FullState.current.activeDay.getDate(), 2);
			list.push(day);
			addChild(day);
			
			var _day:UIText = new UIText(state);
			_day.transformMode = AtlasTransformMode.LOCAL;
			_day.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 24, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
			_day.setTextWidth(100);
			_day.setTextHeight(32);
			_day.text.multiline = false;
			_day.pos.copyXY(day.pos.x, -35);
			_day.text.maxChars = 4;
			_day.text.text = "Day";
			addChild(_day);
		}
	}
	
	public function genColor():Int
	{
		return Util.randomColor(0, 1, 0.3, 0.8, 0.0, 1.0);
	}
	
	public override function customUpdate():Void
	{
		this.prompt.text.textColor = MainScreen.current.scheme1Color;
		this.prompt.text.text = promptText;
		if (!noCancel && backBtn.released) {
			FullState.current.showMainMenu();
			remove();
			return;
		}
		if (type == DialogType.COLOR) {
			for (i in 0...16) {
				if (list[i].released) {
					if (handler != null) handler(list[i].color);
					remove();
				}
			}
			if (list[16].released) for (i in 8...16) list[i].color = genColor();
		}
		else if (type == DialogType.SELECT) {
			for (i in 0...list.length) {
				if (list[i].released) {
					if (handler == "exit") FullState.current.showMainMenu();
					else if (handler != null) handler(options, i);
					remove();
				}
			}
		}
		else if (type == DialogType.TEXT) {
			if (list[1].text.text.length > 0 && !textRestriction.match(list[1].text.text)) {
				list[0].visible = true;
				if (list[0].released || Input.keyPressed(Key.ENTER)) {
					if (handler != null) handler(list[1].text.text);
					remove();
				}
			}
			else {
				list[0].visible = false;
			}
		}
		else if (type == DialogType.LONGTEXT) {
			if (list[0].released) {
				if (handler != null) handler(list[1].text.text);
				remove();
			}
		}
		else if (type == DialogType.TIME) {
			for (i in 3...list.length) {
				if (list[i].released) {
					list[2].text.text = list[i].text.text;
				}
			}
			if (list[1].text.text.length > 0 && !timeRestriction.match(list[1].text.text)) {
				list[0].visible = true;
				if (list[0].released) {
					if (handler != null) handler(Convert.int(list[1].text.text), list[2].text.text);
					remove();
				}
			}
			else {
				list[0].visible = false;
			}
		}
		else if (type == DialogType.DATE) {
			if (list[1].text.text.length > 0 && !timeRestriction.match(list[1].text.text) && list[2].text.text.length > 0 && !timeRestriction.match(list[2].text.text) && list[3].text.text.length > 0 && !timeRestriction.match(list[3].text.text)) {
				if (Convert.int(list[1].text.text) > 1999 && Convert.int(list[1].text.text) < 2100 && Convert.int(list[2].text.text) >= 1 && Convert.int(list[2].text.text) <= 12 && Convert.int(list[3].text.text) >= 1 && Convert.int(list[3].text.text) <= DateTools.getMonthDays(new Date(Convert.int(list[1].text.text), Convert.int(list[2].text.text)-1, 1,0,0,0))){
					list[0].visible = true;
					if (list[0].released || Input.keyPressed(Key.ENTER)) {
						if (handler != null) handler(Convert.int(list[1].text.text), Convert.int(list[2].text.text), Convert.int(list[3].text.text));
						remove();
					}
				}
				else {
					list[0].visible = false;
				}
			}
			else {
				list[0].visible = false;
			}
		}
	}
	
}