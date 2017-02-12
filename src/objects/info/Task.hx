package objects.info;

/**
 * ...
 * @author TommyX
 */
class Task
{
	
	public var name:String;
	public var note:String;
	public var type:String;
	public var priority:Float;//0-1
	public var goalType:String;//none, single, repeat, continuous
	public var goal:Int;//hour - use period x unit when editing
	public var goalTemp:Int;//for calculation only
	public var schedules:Array<Schedule>;

	public function new() 
	{
		name = "";
		note = "";
		type = null;
		priority = 0;
		goalType = "none";
		goal = 0;
		goalTemp = 0;
		schedules = new Array<Schedule>();
	}
	
}