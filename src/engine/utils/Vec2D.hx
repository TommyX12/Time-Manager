package engine.utils;
/**
 * A 2d Vector class to that is mutable.
 *
 * Due to the lack of AS3 operator overloading most methods exists in different names,
 * all methods that ends with Self actually modifies the object itself (including obvious ones copy, copyXY and zero).
 * For example v1 += v2; is written as v1.addSelf(v2);
 *
 * The class in not commented properly yet - just subdivided into logical chunks.
 *
 * @author playchilla.com
 *
 * License: Use it as you wish and if you like it - link back!
 *
 * - ported to haxe by TommyX
 */
class Vec2D extends Vec2DConst
{
    
    public static inline var Epsilon:Float = 0.0000001;
    public static inline var EpsilonSqr:Float = Epsilon * Epsilon;

    public function new(x:Float = 0, y:Float = 0) { super(x, y); }

    /**
     * Copy / assignment
     */
    @:noCompletion override private function set_x(value:Float):Float {
		return _x = value;
	}

    @:noCompletion override private function set_y(value:Float):Float {
		return _y = value;
	}

    public function copy(pos:Vec2DConst):Vec2D
    {
        _x = pos._x;
        _y = pos._y;
        return this;
    }
    public function copyXY(x:Float, y:Float):Vec2D
    {
        _x = x;
        _y = y;
        return this;
    }
    public function zero():Vec2D
    {
        _x = 0;
        _y = 0;
        return this;
    }

    /**
     * Add
     */
    public function addSelf(pos:Vec2DConst):Vec2D
    {
        _x += pos._x;
        _y += pos._y;
        return this;
    }
    public function addXYSelf(x:Float, y:Float):Vec2D
    {
        _x += x;
        _y += y;
        return this;
    }

    /**
     * Sub
     */
    public function subSelf(pos:Vec2DConst):Vec2D
    {
        _x -= pos._x;
        _y -= pos._y;
        return this;
    }
    public function subXYSelf(x:Float, y:Float):Vec2D
    {
        _x -= x;
        _y -= y;
        return this;
    }

    /**
     * Mul
     */
    public function mulSelf(vec:Vec2DConst):Vec2D
    {
        _x *= vec._x;
        _y *= vec._y;
        return this;
    }
    public function mulXYSelf(x:Float, y:Float):Vec2D
    {
        _x *= x;
        _y *= y;
        return this;
    }

    /**
     * Div
     */
    public function divSelf(vec:Vec2DConst):Vec2D
    {
        _x /= vec._x;
        _y /= vec._y;
        return this;
    }
    public function divXYSelf(x:Float, y:Float):Vec2D
    {
        _x /= x;
        _y /= y;
        return this;
    }

    /**
     * Scale
     */
    public function scaleSelf(s:Float):Vec2D
    {
        _x *= s;
        _y *= s;
        return this;
    }

    public function rescaleSelf(newLength:Float):Vec2D
    {
        var nf:Float = newLength / Math.sqrt(_x * _x + _y * _y);
        _x *= nf;
        _y *= nf;
        return this;
    }

    /**
     * Normalize
     */
    public function normalizeSelf():Vec2D
    {
        var nf:Float = 1 / Math.sqrt(_x * _x + _y * _y);
        _x *= nf;
        _y *= nf;
        return this;
    }

    /**
     * Rotate
     */
    public function rotateSelf(rads:Float):Vec2D
    {
        var s:Float = Math.sin(rads);
        var c:Float = Math.cos(rads);
        var xr:Float = _x * c - _y * s;
        _y = _x * s + _y * c;
        _x = xr;
        return this;
    }
    public function normalRightSelf():Vec2D
    {
        var xr:Float = _x;
        _x = -_y;
        _y = xr;
        return this;
    }
    public function normalLeftSelf():Vec2D
    {
        var xr:Float = _x;
        _x = _y;
        _y = -xr;
        return this;
    }
    public function negateSelf():Vec2D
    {
        _x = -_x;
        _y = -_y;
        return this;
    }

    /**
     * Spinor
     */
    public function rotateSpinorSelf(vec:Vec2DConst):Vec2D
    {
        var xr:Float = _x * vec._x - _y * vec._y;
        _y = _x * vec._y + _y * vec._x;
        _x = xr;
        return this;
    }

    /**
     * lerp
     */
    public function lerpSelf(to:Vec2DConst, t:Float):Vec2D
    {
        _x = _x + t * (to._x - _x);
        _y = _y + t * (to._y - _y);
        return this;
    }

    /**
     * Helpers
     */
    public static function swap(a:Vec2D, b:Vec2D):Void
    {
        var x:Float = a._x;
        var y:Float = a._y;
        a._x = b._x;
        a._y = b._y;
        b._x = x;
        b._y = y;
    }
}