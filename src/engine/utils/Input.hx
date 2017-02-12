package engine.utils;

import openfl.display.Sprite;
import openfl.Lib;
import openfl.events.*;

/**
 * ...
 * @author TommyX
 */
class Input extends Sprite
{

	public static var keyDownList:Array<Int> = new Array<Int>();
	public static var keyPressedList:Array<Int> = new Array<Int>();
	public static var keyReleasedList:Array<Int> = new Array<Int>();
	private static var _keyPressedList:Array<Int> = new Array<Int>();
	private static var _keyReleasedList:Array<Int> = new Array<Int>();
	private static var correction:Map<String, Int>;

    public static var rawMousePos(default, null):Vec2D = new Vec2D();

	public static var mousePos(default, null):Vec2D = new Vec2D();
	public static var mouseDown(default, null):Bool = false;
	public static var mousePressed(default, null):Bool = false;
	public static var mouseReleased(default, null):Bool = false;
	private static var mouseHeld:Bool = false;

	public static var rightMouseDown(default, null):Bool = false;
	public static var rightMousePressed(default, null):Bool = false;
	public static var rightMouseReleased(default, null):Bool = false;
	private static var rightMouseHeld:Bool = false;
	
	public static var mouseWheel:Float = 0;
	private static var _mouseWheel:Float = 0;

	public function new()
	{
		super();

		correction = new Map<String, Int>();
		correction.set("0_64", Key.INS);
		correction.set("0_65", Key.END);
		correction.set("0_66", Key.DOWN);
		correction.set("0_67", Key.PAGE_DOWN);
		correction.set("0_68", Key.LEFT);
		correction.set("0_69", -1);
		correction.set("0_70", Key.RIGHT);
		correction.set("0_71", Key.HOME);
		correction.set("0_72", Key.UP);
		correction.set("0_73", Key.PAGE_UP);
		correction.set("0_266", Key.DEL);
		correction.set("123_222", Key.LEFT_SQUARE_BRACKET);
		correction.set("125_187", Key.RIGHT_SQUARE_BRACKET);
		correction.set("126_233", Key.TILDE);

		correction.set("0_80", Key.F1);
		correction.set("0_81", Key.F2);
		correction.set("0_82", Key.F3);
		correction.set("0_83", Key.F4);
		correction.set("0_84", Key.F5);
		correction.set("0_85", Key.F6);
		correction.set("0_86", Key.F7);
		correction.set("0_87", Key.F8);
		correction.set("0_88", Key.F9);
		correction.set("0_89", Key.F10);
		correction.set("0_90", Key.F11);

		correction.set("48_224", Key.DIGIT_0);
		correction.set("49_38", Key.DIGIT_1);
		correction.set("50_233", Key.DIGIT_2);
		correction.set("51_34", Key.DIGIT_3);
		correction.set("52_222", Key.DIGIT_4);
		correction.set("53_40", Key.DIGIT_5);
		correction.set("54_189", Key.DIGIT_6);
		correction.set("55_232", Key.DIGIT_7);
		correction.set("56_95", Key.DIGIT_8);
		correction.set("57_231", Key.DIGIT_9);

		correction.set("48_64", Key.NUMPAD_0);
		correction.set("49_65", Key.NUMPAD_1);
		correction.set("50_66", Key.NUMPAD_2);
		correction.set("51_67", Key.NUMPAD_3);
		correction.set("52_68", Key.NUMPAD_4);
		correction.set("53_69", Key.NUMPAD_5);
		correction.set("54_70", Key.NUMPAD_6);
		correction.set("55_71", Key.NUMPAD_7);
		correction.set("56_72", Key.NUMPAD_8);
		correction.set("57_73", Key.NUMPAD_9);
		correction.set("42_268", Key.NUMPAD_MUL);
		correction.set("43_270", Key.NUMPAD_ADD);
		//correction.set("", Key.NUMPAD_ENTER);
		correction.set("45_269", Key.NUMPAD_SUB);
		correction.set("46_266", Key.NUMPAD_DOT); // point
		correction.set("44_266", Key.NUMPAD_DOT); // comma
		correction.set("47_267", Key.NUMPAD_DIV);

		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        Lib.current.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp);
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
	}

	public static function keyDown(key:Int):Bool
	{
		if (key == Key.ANY) {
			return keyDownList.length > 0;
		}
		return keyDownList.indexOf(key) != -1;
	}

	public static function keyPressed(key:Int):Bool
	{
		if (key == Key.ANY) {
			return keyPressedList.length > 0;
		}
		return keyPressedList.indexOf(key) != -1;
	}

	public static function keyReleased(key:Int):Bool
	{
		if (key == Key.ANY) {
			return keyReleasedList.length > 0;
		}
		return keyReleasedList.indexOf(key) != -1;
	}

	private function keyCode(event:KeyboardEvent):Int
	{
		var code = correction.get(event.charCode + "_" + event.keyCode);
		if (code == null){
			return event.keyCode;
		}
		else{
			return code;
		}
	}

	private function onKeyDown(event:KeyboardEvent):Void
	{
		var code:Int = keyCode(event);
		if (keyDownList.indexOf(code) == -1) keyDownList.push(code);
		_keyPressedList.push(code);
	}

	private function onKeyUp(event:KeyboardEvent):Void
	{	
		var code:Int = keyCode(event);
		var index:Int = keyDownList.indexOf(code);
		if (index != -1) keyDownList.splice(index, 1);
		_keyReleasedList.push(code);
	}

	private function onMouseDown(event:MouseEvent):Void
	{
		mouseDown = true;
		trace(NRFGame.current.mouseX + ", " + NRFGame.current.mouseY);
	}

	private function onMouseUp(event:MouseEvent):Void
	{
		mouseDown = false;
	}

    private function onRightMouseDown(event:MouseEvent):Void
	{
		rightMouseDown = true;
	}

	private function onRightMouseUp(event:MouseEvent):Void
	{
		rightMouseDown = false;
	}
	
	private function onMouseWheel(event:MouseEvent):Void
	{
		_mouseWheel = event.delta;
	}

	private function onEnterFrame(event:Event):Void
	{
		mousePos.x = NRFGame.current.mouseX;
		mousePos.y = NRFGame.current.mouseY;

        rawMousePos.x = Lib.current.stage.mouseX;
		rawMousePos.y = Lib.current.stage.mouseY;

		mousePressed = false;
		mouseReleased = false;
		if (!mouseDown && mouseHeld){
			mouseReleased = true;
		}
		else if (mouseDown && !mouseHeld) {
			mousePressed = true;
		}
		mouseHeld = mouseDown;

		rightMousePressed = false;
        rightMouseReleased = false;
		if (!rightMouseDown && rightMouseHeld){
			rightMouseReleased = true;
		}
		else if (rightMouseDown && !rightMouseHeld) {
			rightMousePressed = true;
		}
		rightMouseHeld = rightMouseDown;
		
		mouseWheel = _mouseWheel;
		_mouseWheel = 0;

		keyPressedList = _keyPressedList.slice(0);
		keyReleasedList = _keyReleasedList.slice(0);
		_keyPressedList = [];
		_keyReleasedList = [];

	}

}