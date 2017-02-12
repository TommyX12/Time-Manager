package engine.objects;

import engine.display.AtlasDisplay;
import engine.display.AtlasTransform;
import engine.display.AtlasTransformMode;
import engine.display.Screen;
import engine.utils.Convert;
import engine.utils.Vec2D;
import engine.utils.Grid;

class AtlasElement
{
	public var stringID:String = "AtlasElement";
	public var nameID:String = "";

	public var layer:AtlasDisplay;
	public var screen:Screen;
	public var parent:AtlasContainer;
	public var animated:Bool;
	public var visible:Bool;

	private var dirty:Bool;
	public var depth:Float;
	public var motionBlur:Bool;
	@:noCompletion public var _lastX:Float;
	@:noCompletion public var _lastY:Float;
	public var pos:Vec2D;
	public var vel:Vec2D;
	public var offset:Vec2D;
    public var gridParent:Grid;
    public var gridIndex:Dynamic;
    public var gridPos:Vec2D;
    public var gridScale:Float;
    public var gridRotation:Float;
	@:noCompletion private var _rotation:Float;
	@:noCompletion private var _rotationCache:Float;
	@:noCompletion private var _rotationCos:Float;
	@:noCompletion private var _rotationSin:Float;
	@:noCompletion private var _scaleX:Float;
	@:noCompletion private var _scaleY:Float;
	@:noCompletion private var _skewX:Float;
	@:noCompletion private var _skewY:Float;
	@:noCompletion private var _localTransform:AtlasTransform;
	public var globalTransform(default, null):AtlasTransform;
	public var transformMode:Int;

	private function new(layer:AtlasDisplay)
	{
		this.layer = layer;
		this.screen = this.layer.screen;
		_localTransform = new AtlasTransform();
		globalTransform = new AtlasTransform();
		motionBlur = false;
		visible = true;
		pos = new Vec2D();
		vel = new Vec2D();
		offset = new Vec2D();	
        gridParent = null;
        gridIndex = null;
        gridPos = new Vec2D();
        gridScale = 0;
        gridRotation = 0;
		_rotation = _skewX = _skewY = 0;
		_scaleX = _scaleY = depth = alpha = 1;
		dirty = true;
		_lastX = -9999;
		_lastY = -9999;
		transformMode = AtlasTransformMode.GLOBAL;
	}

	public function init(layer:AtlasDisplay):Void
	{
		this.layer = layer;
	}

	public function step():Void
	{

	}

	public function remove():Void
	{
		removed();
		if (this.parent != null) {
			this.parent.removeChild(this);
		}
	}
	
	public function internalUpdate():Void
	{
		this.pos.addSelf(this.vel);
	}

	public function update():Void
	{
		//override
	}

	public function backgroundUpdate():Void
	{
		//override
	}

	public function added():Void
	{
		//override
		//called when addChild is called
	}

	public function removed():Void
	{
		//override
		//called when remove()
	}

	public var rotation(get_rotation, set_rotation):Float;
	@:noCompletion private inline function get_rotation():Float { return _rotation; }
	@:noCompletion private function set_rotation(value:Float):Float
	{
		if (_rotation != value) {
			_rotation = value;
			dirty = true;
		}
		return value;
	}

	public var scale(get_scale, set_scale):Float;
	@:noCompletion private inline function get_scale():Float { return (_scaleX + _scaleY) / 2; }
	@:noCompletion private function set_scale(value:Float):Float
	{
		if (_scaleX != value) {
			_scaleX = value;
			_scaleY = value;
			dirty = true;
		}
		return value;
	}

	public var scaleX(get_scaleX, set_scaleX):Float;
	@:noCompletion private inline function get_scaleX():Float { return _scaleX; }
	@:noCompletion private function set_scaleX(value:Float):Float
	{
		if (_scaleX != value) {
			_scaleX = value;
			dirty = true;
		}
		return value;
	}

	public var scaleY(get_scaleY, set_scaleY):Float;
	@:noCompletion private inline function get_scaleY():Float { return _scaleY; }
	@:noCompletion private function set_scaleY(value:Float):Float
	{
		if (_scaleY != value) {
			_scaleY = value;
			dirty = true;
		}
		return value;
	}

	public var skewX(get_skewX, set_skewX):Float;
	@:noCompletion private inline function get_skewX():Float { return _skewX; }
	@:noCompletion private function set_skewX(value:Float):Float
	{
		if (_skewX != value) {
			_skewX = value;
			dirty = true;
		}
		return value;
	}

	public var skewY(get_skewY, set_skewY):Float;
	@:noCompletion private inline function get_skewY():Float { return _skewY; }
	@:noCompletion private function set_skewY(value:Float):Float
	{
		if (_skewY != value) {
			_skewY = value;
			dirty = true;
		}
		return value;
	}

	public var alpha(get_alpha, set_alpha):Float;
	@:noCompletion private inline function get_alpha():Float { return _localTransform.alpha; }
	@:noCompletion private function set_alpha(value:Float):Float
	{
		return _localTransform.alpha = value;
	}

	public var localTransform(get_localTransform, null):AtlasTransform;
	@:noCompletion private function get_localTransform():AtlasTransform
	{
		if (dirty)
		{
			dirty = false;
			var sx:Float = scaleX * layer.tilesheet.scale;
			var sy:Float = scaleY * layer.tilesheet.scale;
			if (rotation != 0) {
				if (rotation != _rotationCache) {
					_rotationCache = rotation;
					var radians:Float = Convert.rad(rotation);
					_rotationSin = Math.sin(radians);
					_rotationCos = Math.cos(radians);
				}
				if (skewX != 0 || skewY != 0) {
					var skx:Float = skewX * layer.tilesheet.scale;
					var sky:Float = skewY * layer.tilesheet.scale;
					_localTransform.a = sx * (_rotationCos - _rotationSin * sky);
					_localTransform.b = sx * (_rotationSin + _rotationCos * sky);
					_localTransform.c = sy * (_rotationCos * skx - _rotationSin);
					_localTransform.d = sy * (_rotationCos + _rotationSin * skx);
				}
				else {
					_localTransform.a = _rotationCos * sx;
					_localTransform.b = _rotationSin * sx;
					_localTransform.c = -_rotationSin * sy;
					_localTransform.d = _rotationCos * sy;
				}
			}
			else {
				if (skewX != 0 || skewY != 0) {
					var skx:Float = skewX * layer.tilesheet.scale;
					var sky:Float = skewY * layer.tilesheet.scale;
					_localTransform.a = sx;
					_localTransform.b = sx * sky;
					_localTransform.c = sy * skx;
					_localTransform.d = sy;
				}
				else {
					_localTransform.a = sx;
					_localTransform.b = 0;
					_localTransform.c = 0;
					_localTransform.d = sy;
				}
			}
		}
		if (offset.x != 0 || offset.y != 0) {
			_localTransform.tx = pos.x - offset.x / layer.tilesheet.scale * _localTransform.a - offset.y / layer.tilesheet.scale * _localTransform.c;
			_localTransform.ty = pos.y - offset.x / layer.tilesheet.scale * _localTransform.b - offset.y / layer.tilesheet.scale * _localTransform.d;
		}
		else {
			_localTransform.tx = pos.x;
			_localTransform.ty = pos.y;
		}
		return _localTransform;
	}

	public function toString():String
	{
		return stringID + "-" + nameID + " x:" + Convert.string(pos.x) + " y:" + Convert.string(pos.y);
	}

}