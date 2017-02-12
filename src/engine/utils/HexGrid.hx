package engine.utils;

import engine.utils.Convert;

class HexGrid extends Grid{

    public function new(gridSize:Int, blockSize:Float, scale:Float=1, rotation:Float=0):Void
    {
        super(gridSize, blockSize, scale, rotation);
    }

    override private function initializeData():Void
    {
        this.data = new Array<Array<Dynamic>>();
        var rows:Int = gridSize*2-1;
        for (i in 0...rows){
            data.push(new Array<Dynamic>());
            for (j in 0...Convert.int(rows-Math.abs(gridSize-i-1))){
                data[i].push(null);
            }
        }
    }

    override private function updateMatrix():Void
    {
        a = scale * blockSize * Math.cos(Convert.rad(rotation+30));
        b = scale * blockSize * Math.cos(Convert.rad(rotation+90));
        c = scale * blockSize * Math.sin(Convert.rad(rotation+30));
        d = scale * blockSize * Math.sin(Convert.rad(rotation+90));
        det = 1 / (a*d-b*c);
        dirty = false;
    }
	
	override public function getCoordTo(index:Dynamic, vec:Vec2D):Vec2D
	{
		if (dirty) updateMatrix();
        return vec.copyXY(pos.x + a * index[0] + b * index[1], pos.y + c * index[0] + d * index[1]);
	}

    override public function getCoord(index:Dynamic):Vec2DConst
    {
        if (dirty) updateMatrix();
        return new Vec2DConst(pos.x + a * index[0] + b * index[1], pos.y + c * index[0] + d * index[1]);
    }

    override public function getIndex(pos:Vec2DConst):Dynamic
    {
        if (dirty) updateMatrix();
        var __x:Float = pos.x - this.pos.x;
        var __y:Float = pos.y - this.pos.y;
        var row:Float = det * (d*__x-b*__y);
        var column:Float = det * (a*__y-c*__x);
        var sectorRow:Int = Math.floor(row);
        var sectorColumn:Int = Math.floor(column);
        row -= sectorRow;
        column -= sectorColumn;

        if (row > column){
            if (column < -2 * row + 1) return [sectorRow, sectorColumn];
            if (column > -0.5 * row + 1) return [sectorRow+1, sectorColumn+1];
            return [sectorRow+1, sectorColumn];
        }
        else {
            if (column < -0.5 * row + 0.5) return [sectorRow, sectorColumn];
            if (column > -2 * row + 2) return [sectorRow+1, sectorColumn+1];
            return [sectorRow, sectorColumn+1];
        }

        return null;
    }

    override public function getIndexExtended(pos:Vec2DConst):Array<Dynamic>
    {
        if (dirty) updateMatrix();
        var __x:Float = pos.x - this.pos.x;
        var __y:Float = pos.y - this.pos.y;
        var row:Float = det * (d*__x-b*__y);
        var column:Float = det * (a*__y-c*__x);
        var sectorRow:Int = Math.floor(row);
        var sectorColumn:Int = Math.floor(column);
        row -= sectorRow;
        column -= sectorColumn;

        if (row > column){
            if (column < -2 * row + 1) return [[sectorRow, sectorColumn],[sectorRow+1, sectorColumn],5];
            if (column > -0.5 * row + 1) return [[sectorRow+1, sectorColumn+1],[sectorRow+1, sectorColumn],3];
            if (column < -0.5 * row + 0.5) return [[sectorRow+1, sectorColumn],[sectorRow, sectorColumn],2];
            if (column > -2 * row + 2) return [[sectorRow+1, sectorColumn],[sectorRow+1, sectorColumn+1],0];
            return [[sectorRow+1, sectorColumn],[sectorRow, sectorColumn+1],1];
        }
        else {
            if (column < -0.5 * row + 0.5) return [[sectorRow, sectorColumn],[sectorRow, sectorColumn+1],0];
            if (column > -2 * row + 2) return [[sectorRow+1, sectorColumn+1],[sectorRow, sectorColumn+1],2];
            if (column < -2 * row + 1) return [[sectorRow, sectorColumn+1],[sectorRow, sectorColumn],3];
            if (column > -0.5 * row + 1) return [[sectorRow, sectorColumn+1],[sectorRow+1, sectorColumn+1],5];
            return [[sectorRow, sectorColumn+1],[sectorRow+1, sectorColumn],4];
        }

        return null;
    }

    override public function getEdges(index:Dynamic):Array<Dynamic>
    {
        return [
            [index[0]+0, index[1]+1],
            [index[0]-1, index[1]+1],
            [index[0]-1, index[1]+0],
            [index[0]+0, index[1]-1],
            [index[0]+1, index[1]-1],
            [index[0]+1, index[1]+0]
        ];
    }
	
	override public function getEdge(index:Dynamic, dir:Int):Dynamic
    {
        switch (dir) 
		{
			case 0:
				return [index[0] + 0, index[1] + 1];
			case 1:
				return [index[0] - 1, index[1] + 1];
			case 2:
				return [index[0] - 1, index[1] + 0];
			case 3:
				return [index[0] + 0, index[1] - 1];
			case 4:
				return [index[0] + 1, index[1] - 1];
			case 5:
				return [index[0] + 1, index[1] + 0];
			default:
				return null;
		}
    }

    override public function getEdgeDir(index:Dynamic, edge:Dynamic):Int
    {
        if (edge[0]-index[0] == 0 && edge[1]-index[1] == 1) return 0;
        if (edge[0]-index[0] == -1 && edge[1]-index[1] == 1) return 1;
        if (edge[0]-index[0] == -1 && edge[1]-index[1] == 0) return 2;
        if (edge[0]-index[0] == 0 && edge[1]-index[1] == -1) return 3;
        if (edge[0]-index[0] == 1 && edge[1]-index[1] == -1) return 4;
        if (edge[0]-index[0] == 1 && edge[1]-index[1] == 0) return 5;
        return -1;
    }

    override public function get(index:Dynamic):Dynamic
    {
        if (index[0] < -gridSize+1 || index[0] > gridSize-1) return "[out of bound]";
        if (index[1] < -Math.min(index[0], 0)-gridSize+1 || index[1] > -Math.max(index[0], 0)+gridSize-1) return "[out of bound]";
        return data[Convert.int(index[0] + gridSize-1)][Convert.int(index[1] + gridSize-1 + Math.min(index[0], 0))];
    }

    override public function set(index:Dynamic, value:Dynamic):Bool
    {
		if (index[0] < -gridSize+1 || index[0] > gridSize-1) return false;
        if (index[1] < -Math.min(index[0], 0)-gridSize+1 || index[1] > -Math.max(index[0], 0)+gridSize-1) return false;
        data[Convert.int(index[0] + gridSize-1)][Convert.int(index[1] + gridSize-1 + Math.min(index[0], 0))] = value;
        return true;
    }

	override public function gridIndex(dataIndex:Dynamic):Dynamic
	{
		return [dataIndex[0] - gridSize+1, Convert.int(dataIndex[1] - Math.min(dataIndex[0], gridSize-1))];
	}
}