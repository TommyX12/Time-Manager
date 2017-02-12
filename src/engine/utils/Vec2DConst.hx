package engine.utils;
    /**
     * A 2d Vector class to perform constant operations. Use this class to make sure that objects stay consts, e.g.
     * public function getPos():Vec2DConst { return _pos; } // pos is not allowed to change outside of bot.
     *
     * Many method has a postfix of XY - this allows you to operate on the components directly i.e.
     * instead of writing add(new Vec2D(1, 2)) you can directly write addXY(1, 2);
     *
     * For performance reasons I am not using an interface for read only specification since internally it should be possible
     * to use direct access to x and y. Externally x and y is obtained via getters which are a bit slower than direct access of
     * a public variable. I suggest you stick with this during development. If there is a bottleneck you can just remove the get
     * accessors and directly expose _x and _y (rename it to x and replace all _x and _y to this.x, this.y internally).
     *
     * The class in not commented properly yet - just subdivided into logical chunks.
     *
     * @author playchilla.com
     *
     * License: Use it as you wish and if you like it - link back!
     *
     * - ported to haxe by TommyX
     */
class Vec2DConst {
	
	public static var Zero(default, null):Vec2DConst = new Vec2DConst();
    private static var _RadsToDeg:Float = 180 / Math.PI;

    private var _x:Float;
    private var _y:Float;

    public var x(get, set):Float;
    @:noCompletion private function get_x():Float { return _x; }
    @:noCompletion private function set_x(value:Float):Float {
		return value;
	}

    public var y(get, set):Float;
    @:noCompletion private function get_y():Float { return _y; }
    @:noCompletion private function set_y(value:Float):Float {
		return value;
	}
	
	public static function createFromRandDir(distance:Float=1.0):Vec2DConst
    {
        var rads:Float = Math.random() * Math.PI * 2;
        return new Vec2DConst(Math.cos(rads) * distance, Math.sin(rads) * distance);
    }
	
	public static function createFromDir(angle:Float, distance:Float=1.0, radian:Bool=false):Vec2DConst
    {
        var rads:Float = radian ? angle : angle / 180 * Math.PI;
        return new Vec2DConst(Math.cos(rads) * distance, Math.sin(rads) * distance);
    }

    public function new(x:Float = 0, y:Float = 0):Void
    {
        _x = x;
        _y = y;
    }

    public function clone():Vec2D { return new Vec2D(_x, _y); }

    /**
     * Add, sub, mul and div
     */
    public function add(pos:Vec2DConst):Vec2D { return new Vec2D(_x + pos._x, _y + pos._y); }
    public function addXY(x:Float, y:Float):Vec2D { return new Vec2D(_x + x, _y + y); }

    public function sub(pos:Vec2DConst):Vec2D { return new Vec2D(_x - pos._x, _y - pos._y); }
    public function subXY(x:Float, y:Float):Vec2D { return new Vec2D(_x - x, _y - y); }

    public function mul(vec:Vec2DConst):Vec2D { return new Vec2D(_x * vec._x, _y * vec._y); }
    public function mulXY(x:Float, y:Float):Vec2D { return new Vec2D(_x * x, _y * y); }

    public function div(vec:Vec2DConst):Vec2D { return new Vec2D(_x / vec._x, _y / vec._y); }
    public function divXY(x:Float, y:Float):Vec2D { return new Vec2D(_x / x, _y / y); }

    /**
     * Scale
     */
    public function scale(s:Float):Vec2D { return new Vec2D(_x * s, _y * s); }

    public function rescale(newLength:Float):Vec2D
    {
        var nf:Float = newLength / Math.sqrt(_x * _x + _y * _y);
        return new Vec2D(_x * nf, _y * nf);
    }

    /**
     * Normalize
     */
    public function normalize():Vec2D
    {
        var nf:Float = 1 / Math.sqrt(_x * _x + _y * _y);
        return new Vec2D(_x * nf, _y * nf);
    }

    /**
     * Distance
     */
    public function length():Float { return Math.sqrt(_x * _x + _y * _y); }
    public function lengthSqr():Float { return _x * _x + _y * _y; }
    public function distance(vec:Vec2DConst):Float
    {
        var xd:Float = _x - vec._x;
        var yd:Float = _y - vec._y;
        return Math.sqrt(xd * xd + yd * yd);
    }
    public function distanceXY(x:Float, y:Float):Float
    {
        var xd:Float = _x - x;
        var yd:Float = _y - y;
        return Math.sqrt(xd * xd + yd * yd);
    }
    public function distanceSqr(vec:Vec2DConst):Float
    {
        var xd:Float = _x - vec._x;
        var yd:Float = _y - vec._y;
        return xd * xd + yd * yd;
    }
    public function distanceXYSqr(x:Float, y:Float):Float
    {
        var xd:Float = _x - x;
        var yd:Float = _y - y;
        return xd * xd + yd * yd;
    }

    /**
     * Queries.
     */
    public function equals(vec:Vec2DConst):Bool { return _x == vec._x && _y == vec._y; }
    public function equalsXY(x:Float, y:Float):Bool { return _x == x && _y == y; }
    public function isNormalized():Bool { return Math.abs((_x * _x + _y * _y)-1) < Vec2D.EpsilonSqr; }
    public function isZero():Bool { return _x == 0 && _y == 0; }
    public function isNear(vec2:Vec2DConst):Bool { return distanceSqr(vec2) < Vec2D.EpsilonSqr; }
    public function isNearXY(x:Float, y:Float):Bool { return distanceXYSqr(x, y) < Vec2D.EpsilonSqr; }
    public function isWithin(vec2:Vec2DConst, epsilon:Float):Bool { return distanceSqr(vec2) < epsilon*epsilon; }
    public function isWithinXY(x:Float, y:Float, epsilon:Float):Bool { return distanceXYSqr(x, y) < epsilon*epsilon; }
    public function isValid():Bool { return !Math.isNaN(_x) && !Math.isNaN(_y) && Math.isFinite(_x) && Math.isFinite(_y); }
    public function getDegrees():Float { return getRads() * _RadsToDeg; }
    public function getRads():Float { return Math.atan2(_y, _x); }
    public function getRadsBetween(vec:Vec2DConst):Float { return Math.atan2(x - vec.x, y - vec.y); }

    /**
     * Dot product
     */
    public function dot(vec:Vec2DConst):Float { return _x * vec._x + _y * vec._y; }
    public function dotXY(x:Float, y:Float):Float { return _x * x + _y * y; }

    /**
     * Cross determinant
     */
    public function crossDet(vec:Vec2DConst):Float { return _x * vec._y - _y * vec._x; }
    public function crossDetXY(x:Float, y:Float):Float { return _x * y - _y * x; }

    /**
     * Rotate
     */
    public function rotate(rads:Float):Vec2D
    {
        var s:Float = Math.sin(rads);
        var c:Float = Math.cos(rads);
        return new Vec2D(_x * c - _y * s, _x * s + _y * c);
    }
    public function normalRight():Vec2D { return new Vec2D(-_y, _x); }
    public function normalLeft():Vec2D { return new Vec2D(_y, -_x); }
    public function negate():Vec2D { return new Vec2D( -_x, -_y); }

    /**
     * Spinor rotation
     */
    public function rotateSpinorXY(x:Float, y:Float):Vec2D { return new Vec2D(_x * x - _y * y, _x * y + _y * x); }
    public function rotateSpinor(vec:Vec2DConst):Vec2D { return new Vec2D(_x * vec._x - _y * vec._y, _x * vec._y + _y * vec._x); }
    public function spinorBetween(vec:Vec2DConst):Vec2D
    {
        var d:Float = lengthSqr();
        var r:Float = (vec._x * _x + vec._y * _y) / d;
        var i:Float = (vec._y * _x - vec._x * _y) / d;
        return new Vec2D(r, i);
    }

    /**
     * Lerp / slerp
     * Note: Slerp is not well tested yet.
     */
    public function lerp(to:Vec2DConst, t:Float):Vec2D { return new Vec2D(_x + t * (to._x - _x), _y + t * (to._y - _y)); }

    public function slerp(vec:Vec2DConst, t:Float):Vec2D
    {
        var cosTheta:Float = dot(vec);
        var theta:Float = Math.acos(cosTheta);
        var sinTheta:Float = Math.sin(theta);
        if (sinTheta <= Vec2D.Epsilon)
            return vec.clone();
        var w1:Float = Math.sin((1 - t) * theta) / sinTheta;
        var w2:Float = Math.sin(t * theta) / sinTheta;
        return scale(w1).add(vec.scale(w2));
    }

    /**
     * Reflect
     */
    public function reflect(normal:Vec2DConst):Vec2D
    {
        var d:Float = 2 * (_x * normal._x + _y * normal._y);
        return new Vec2D(_x - d * normal._x, _y - d * normal._y);
    }

    /**
     * String
     */
    public function toString():String { return "[" + _x + ", " + _y + "]"; }

    public function getMin(p:Vec2DConst):Vec2D { return new Vec2D(Math.min(p._x, _x), Math.min(p._y, _y)); }
    public function getMax(p:Vec2DConst):Vec2D { return new Vec2D(Math.max(p._x, _x), Math.max(p._y, _y)); }

}