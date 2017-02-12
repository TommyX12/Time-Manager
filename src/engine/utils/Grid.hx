package engine.utils;

import engine.utils.Convert;

class Grid {

    public var data:Dynamic;
    public var gridSize(default, null):Int;
    public var blockSize:Float;

    private var a:Float;
    private var b:Float;
    private var c:Float;
    private var d:Float;
    private var det:Float;

    public var pos:Vec2D;

    public var scale(default, set):Float;
    @:noCompletion private function set_scale(value:Float):Float {
        dirty = true;
		return scale = value;
	}

    public var rotation(default, set):Float;
    @:noCompletion private function set_rotation(value:Float):Float {
        dirty = true;
		return rotation = value;
	}

    private var dirty:Bool;

    private function new(gridSize:Int, blockSize:Float, scale:Float=1, rotation:Float=0):Void
    {
        this.gridSize = gridSize;
        this.blockSize = blockSize;
        this.pos = new Vec2D();
        this.scale = scale;
        this.rotation = rotation;
        this.dirty = true;
		initializeData();
    }

    private function updateMatrix():Void
    {
        //override
        a = scale * blockSize * Math.cos(Convert.rad(rotation));
        b = scale * blockSize * -Math.sin(Convert.rad(rotation));
        c = scale * blockSize * Math.sin(Convert.rad(rotation));
        d = scale * blockSize * Math.cos(Convert.rad(rotation));
        det = 1 / (a*d-b*c);
        dirty = false;
    }

    private function initializeData():Void
    {
        //override
    }
	
	public function getCoordTo(index:Dynamic, vec:Vec2D):Vec2D
	{
		//override
		if (dirty) updateMatrix();
        return vec.copyXY(pos.x + a * index[0] + b * index[1], pos.y + c * index[0] + d * index[1]);
	}

    public function getCoord(index:Dynamic):Vec2DConst
    {
        //override
        if (dirty) updateMatrix();
        return new Vec2DConst(pos.x + a * index[0] + b * index[1], pos.y + c * index[0] + d * index[1]);
    }

    public function getIndex(pos:Vec2DConst):Dynamic
    {
        //override
        return null;
    }
	
	public function getIndexExtended(pos:Vec2DConst):Array<Dynamic>
    {
        //override
        return null;
    }
	
	public function getEdges(index:Dynamic):Array<Dynamic>
    {
        //override
		return null;
    }
	
	public function getEdge(index:Dynamic, dir:Dynamic):Dynamic
    {
        //override
		return null;
    }

    public function getEdgeDir(index:Dynamic, edge:Dynamic):Int
    {
		//override
        return -1;
    }

    public function get(index:Dynamic):Dynamic
    {
        //override
        return null;
    }

    public function set(index:Dynamic, value:Dynamic):Bool
    {
        //override
        return true;
    }

	public function gridIndex(dataIndex:Dynamic):Dynamic
	{
        //override
		return null;
	}
}