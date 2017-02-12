package engine.objects;

import engine.display.AtlasDisplay;
import engine.objects.AtlasContainer;
import engine.objects.AtlasEntity;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import engine.utils.Grid;
import engine.utils.Convert;


class AtlasContainer extends AtlasElement
{
	public var children:Array<AtlasElement>;

    public var grid(default, set):Grid;
    @:noCompletion private function set_grid(value:Grid):Grid
	{
        for (child in children) {
            child.gridParent = value;
        }
		if (value != null){
			value.pos = this.pos;
		}
		return grid = value;
	}

	public function new(layer:AtlasDisplay, grid:Grid=null)
	{
		super(layer);
        children = new Array<AtlasElement>();
        this.grid = grid;
		stringID = "AtlasContainer";
	}

	override public function init(layer:AtlasDisplay):Void
	{
		this.layer = layer;
		if (children != null) initChildren();
	}

	private inline function initChild(item:AtlasElement)
	{
		item.parent = this;
        item.gridParent = this.grid;
		item.added();
		if (layer != null)
			item.init(layer);
	}

	private function initChildren()
	{
		for(child in children)
			initChild(child);
	}

	public inline function indexOf(item:AtlasElement):Int
	{
		return Lambda.indexOf(children, item);
	}

	public function addChild(item:AtlasElement):Int
	{
		if (item.parent != null) item.parent.removeChild(item);
		initChild(item);
		return children.push(item);
	}

	public function addChildAt(item:AtlasElement, index:Int):Int
	{
		removeChild(item);
		initChild(item);
		children.insert(index, item);
		return index;
	}

	public function removeChild(item:AtlasElement):AtlasElement
	{
		if (item != null){
			if (item.parent == null) return item;
			if (item.parent != this) {
				trace("Invalid parent");
				return item;
			}
			var index = indexOf(item);
			if (index >= 0)
			{
				children.splice(index, 1);
				item.parent = null;
			}
		}
		return item;
	}

	public function removeChildAt(index:Int):AtlasElement
	{
		var child = children.splice(index, 1)[0];
		if (child != null) {
			child.parent = null;
		}
		return child;
	}

	public function removeAllChildren():Array<AtlasElement>
	{
		for (child in children) {
			child.parent = null;
		}
		return children.splice(0, children.length);
	}

    public function updateChildrenGrid():Void
    {
        if (grid != null) {
			grid.scale = this.scale;
			grid.rotation = this.rotation;
            for (child in children) {
                if (child.gridIndex != null){
                    child.gridPos.copy(grid.getCoord(child.gridIndex));
                    child.gridScale = grid.scale;
                    child.gridRotation = grid.rotation;
                }
            }
        }
    }

	public function getChildIndex(item:AtlasElement):Int
	{
		return indexOf(item);
	}

	public function setChildIndex(item:AtlasElement, index:Int)
	{
		var oldIndex = indexOf(item);
		if (oldIndex >= 0 && index != oldIndex)
		{
			children.splice(oldIndex, 1);
			children.insert(index, item);
		}
	}

	public inline function iterator() { return children.iterator(); }

	public var numChildren(get_numChildren, null):Int;
	@:noCompletion private inline function get_numChildren() { return children != null ? children.length : 0; }

	/*
	public var height(get_height, null):Float; // TOFIX incorrect with sub groups
	@:noCompletion private function get_height():Float
	{
		if (numChildren == 0) return 0;
		var ymin = 9999.0, ymax = -9999.0;
		for(child in children)
			if (Convert.is(child, AtlasEntity)) {
				var sprite:AtlasEntity = cast child;
				var h = sprite.height;
				var top = sprite.pos.y - h/2;
				var bottom = top + h;
				if (top < ymin) ymin = top;
				if (bottom > ymax) ymax = bottom;
			}
		return ymax - ymin;
	}

	public var width(get_width, null):Float; // TOFIX incorrect with sub groups
	@:noCompletion private function get_width():Float
	{
		if (numChildren == 0) return 0;
		var xmin = 9999.0, xmax = -9999.0;
		for(child in children)
			if (Convert.is(child, AtlasEntity)) {
				var sprite:AtlasEntity = cast child;
				var w = sprite.width;
				var left = sprite.pos.x - w/2;
				var right = left + w;
				if (left < xmin) xmin = left;
				if (right > xmax) xmax = right;
			}
		return xmax - xmin;
	}
	*/
}