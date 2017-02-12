package objects.info;

/**
 * ...
 * @author TommyX
 */
class Project extends Task
{
	
	public var subtasks:Array<Dynamic>; //timeReq(Int), name(String) //if time req is -1: its deadline, with date(Date)

	public function new() 
	{
		super();
		subtasks = [];
		goalType = "project";
	}
	
}