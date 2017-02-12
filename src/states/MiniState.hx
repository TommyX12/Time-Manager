package states;

import objects.primitive.UIButton;
import objects.StartBtn;
import engine.NRFDisplay;
import engine.display.AtlasTransformMode;
import screens.MainScreen;
import openfl.Lib;
import openfl.display.StageDisplayState;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import objects.primitive.UIText;

/**
 * ...
 * @author TommyX
 */
class MiniState extends State
{
	
	public var startBtn:StartBtn;
	public var alerted:Bool;
	public var text:UIText;
	
	public var t:Float;

	public function new()
	{
		super();
		
		startBtn = new StartBtn(this);
		startBtn.transformMode = AtlasTransformMode.LOCAL;
		this.addChild(startBtn);
		startBtn.pos.copyXY(0, 100);
		
		alerted = false;
		
		text = new UIText(this);
		text.transformMode = AtlasTransformMode.GLOBAL;
		text.pos = this.pos;
		this.addChild(text);
		text.setTextWidth(200);
		text.setTextHeight(100);
		text.textPos.mulXYSelf(5, 5);
		text.textPos.subXYSelf(0, 200);
		text.text.scaleX = text.text.scaleY = 5;
		text.text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 40, 0x000000, true, null, null, null, null, TextFormatAlign.CENTER);
		
		t = 0;
		
		trace(MyExtension.sampleMethod(5));
	}
	
	public override function update():Void
	{
		if (activated) {
			if (alerted) {
				this.scale = Math.sin(t)*0.15+1;
				t += 0.3;
				if (t > 31415) t = 0;
			}
			else this.scale = 1;
			this.pos.copy(NRFDisplay.centerPos);
			if (startBtn.released) {
				MainScreen.current.state_full.show();
				if (MainScreen.current.state_full.mainMenu != null) MainScreen.current.state_full.mainMenu.checkActiveTask = true;
				Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				hide();
			}
		}
	}
	
}