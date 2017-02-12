package objects;

import objects.info.Schedule;
import objects.info.Task;
import objects.primitive.UIButton;
import states.State;
import engine.utils.*;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import screens.MainScreen;
import states.FullState;
import screens.MainScreen;

/**
 * ...
 * @author TommyX
 */
class TaskMarker extends UIButton
{
	
	public var startMinute:Int;
	public var endMinute:Int;
	public var schedule:Schedule;
	public var task:Task;

	public function new(state:State) 
	{
		super(state, "_gradientwline");
		
		this.offset.x = -this.size.width / 2;
		this.width = 420;
		this.height = 10;
		this.color = 0xFF0000;
		this.luminance = 1.25;
		
		text.defaultTextFormat = new TextFormat(MainScreen.TEXT_FONT_NAME, 22, 0x000000, true, null, null, null, null, TextFormatAlign.LEFT);
		text.width = 600;
		this.width = 420;
		textPos.copyXY(-this.width/2 + 32, -16);
		text.height = 32;
		text.textColor = 0xFFFFFF;
		text.alpha = 0;
	}
	
	public function setTask(task:Task) {
		this.color = MainScreen.data_tasktypes_color[MainScreen.data_tasktypes_name.indexOf(task.type)];
		text.text = task.name;
		this.task = task;
	}
	
	public function setSchedule(schedule:Schedule) {
		this.startMinute = schedule.startMinute;
		this.endMinute = schedule.endMinute;
		setTime(schedule.startMinute, schedule.endMinute);
		this.schedule = schedule;
		if (schedule.isAuto) text.text = "+ " + task.name;
	}
	
	public function setTime(startMinute:Int, endMinute:Int) {
		this.startMinute = startMinute;
		this.endMinute = endMinute;
		this.height = TimeLine.length * (Math.abs(endMinute - startMinute) / 1440);
		this.pos.copyXY(0, TimeLine.length * (endMinute + startMinute)/2880);
	}
	
	public override function colorUpdate():Void
	{
		
	}
	
	public override function buttonUpdate():Void
    {
        bound.width = this.width * this.parent.scaleX;
        bound.height = this.height * this.parent.scaleY;
		bound.x = this.parent.pos.x + (this.pos.x) * this.parent.scaleX;
		bound.y = this.parent.pos.y + (this.pos.y - this.height / 2) * this.parent.scaleY;
        pressed = false;
        released = false;
        if (this.visible && bound.contains(Input.mousePos.x, Input.mousePos.y)){
            if (!hover) {
				hover = true;
				onHover();
			}
            if (Input.mousePressed){
                down = true;
                pressed = true;
				onPressed();
            }
        }
        else hover = false;
		if (Input.mouseReleased) {
			if (down) {
				if (hover){
					released = true;
					onReleased();
				}
				down = false;
			}
		}
    }
	
	public override function customUpdate():Void
	{
		this.width = Math.max(420, text.textWidth+85);
		textPos.copyXY(-this.width/2 + 17, -16);
		if (this.height * this.parent.scaleY < 20) text.alpha += (0.0 - text.alpha) * 0.5;
		else text.alpha += (1.0 - text.alpha) * 0.5;
	}
	
}