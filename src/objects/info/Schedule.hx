package objects.info;

/**
 * ...
 * @author TommyX
 */
class Schedule
{
	
	public var startMinute:Int;
	public var endMinute:Int;
	public var repeatPeriod:Int;//how many unit - no fractional value
	public var repeatUnit:String;//day, week, month, year
	public var start:Date;//day
	public var end:Date;//day, inclusive
	public var numOfTimes:Int;//0 = inf
	public var isAuto:Bool;
	public var canceled:Array<Float>;

	public function new() 
	{
		startMinute = 0;
		endMinute = 0;
		repeatPeriod = 1;
		repeatUnit = "day";
		start = null;
		end = null;
		isAuto = false;
		numOfTimes = 0;
		canceled = new Array<Float>();
	}
	
}