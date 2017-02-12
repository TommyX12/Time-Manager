package engine.utils;

import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author TommyX
 */
class Util
{
	
	public static function closestPow2(v:Int):Int
	{
		var p:Int = 2;
		while (p < v) p = p << 1;
		return p;
	}
	
	public static function getFileNameNumber(number:Int, digitCount:Int):String
	{
		var str:String = Convert.string(number);
		var zeroCount:Int = digitCount - str.length;
		for (i in 0...zeroCount) {
			str = "0" + str;
		}
		return str;
	}
	
	public static function map(x:Float, in_min:Float, in_max:Float, out_min:Float, out_max:Float):Float
	{
	  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
	}
	
	public static function random(min:Float, max:Float):Float 
	{
		return Math.random() * (max - min) + min;
	}
	
	public static function randomInt(max:Int):Int 
	{
		return Std.random(max);
	}
    
    public static function randomSelect(options:Int, chances:Array<Float>=null):Int
    {
        if (chances == null) return randomInt(options);
        var pointer:Int = 0;
        var total:Float = 0;
        for (i in chances) total += i;
        var rand:Float = random(0, total);
        while (pointer < options-1){
            if (rand < chances[pointer]) break;
            rand -= chances[pointer];
            total -= chances[pointer];
            pointer++;
        }
		return pointer;
    }
	
	public static function randomColor(hueMin:Float, hueMax:Float, luminanceMin:Float, luminanceMax:Float, saturationMin:Float, saturationMax:Float):Int
	{
		var h:Float = random(hueMin, hueMax);
		var l:Float = random(luminanceMin, luminanceMax);
		var s:Float = random(saturationMin, saturationMax);
		var t2:Float = (l<=0.5)? l*(1+s):l+s-(l*s);
		var t1:Float = 2*l-t2;
		var t3:Array<Float> = new Array<Float>();
		t3.push(h+1/3);
		t3.push(h);
		t3.push(h-1/3);
		var clr:Array<Float> = new Array<Float>();
		clr.push(0);
		clr.push(0);
		clr.push(0);
		for(i in 0...3)
		{
			if(t3[i]<0)
				t3[i]+=1;
			if(t3[i]>1)
				t3[i]-=1;

			if(6*t3[i] < 1)
				clr[i]=t1+(t2-t1)*t3[i]*6;
			else if(2*t3[i]<1)
				clr[i]=t2;
			else if(3*t3[i]<2)
				clr[i]=(t1+(t2-t1)*((2/3)-t3[i])*6);
			else
				clr[i]=t1;
		}
		return Convert.colorFloat(clr[0], clr[1], clr[2]);
	}
	
	public static function rotationDist(start:Float, end:Float, useRadians:Bool = false):Float
	{
		var cap:Float = useRadians ? Math.PI * 2 : 360;
		var dif:Float = (end - start) % cap;
		if (dif != dif % (cap / 2)) {
			dif = (dif < 0) ? dif + cap : dif - cap;
		}
		return dif;
	}
	
	public static function getDistanceXY(targetX:Float, targetY:Float, originX:Float = 0, originY:Float = 0):Float
	{
		return Math.sqrt((targetX - originX) * (targetX - originX) + (targetY - originY) * (targetY - originY));
	}
	
	public static function getDistance(target:Vec2DConst, origin:Vec2DConst):Float
	{
		return Math.sqrt((target.x - origin.x) * (target.x - origin.x) + (target.y - origin.y) * (target.y - origin.y));
	}
	
	public static function getAngleXY(targetX:Float, targetY:Float, originX:Float = 0, originY:Float = 0, radian:Bool = false):Float 
	{
		var dx:Float = targetX - originX;  
		var dy:Float = targetY - originY;
		return radian ? Math.atan2(dy, dx) : Math.atan2(dy, dx) * 180 / Math.PI;
	}
	
	public static function getAngle(target:Vec2DConst, origin:Vec2DConst, radian:Bool = false):Float 
	{
		var dx:Float = target.x - origin.x;  
		var dy:Float = target.y - origin.y;
		return radian ? Math.atan2(dy, dx) : Math.atan2(dy, dx) * 180 / Math.PI;
	}
	
	public static function hitTestLine2Rect(p1:Point, p2:Point, r:Rectangle):Bool
	{
		return hitTestLine2Line(p1, p2, new Point(r.x, r.y), new Point(r.x + r.width, r.y)) ||
			   hitTestLine2Line(p1, p2, new Point(r.x + r.width, r.y), new Point(r.x + r.width, r.y + r.height)) ||
			   hitTestLine2Line(p1, p2, new Point(r.x + r.width, r.y + r.height), new Point(r.x, r.y + r.height)) ||
			   hitTestLine2Line(p1, p2, new Point(r.x, r.y + r.height), new Point(r.x, r.y)) ||
			   (r.contains(p1.x,p1.y) && r.contains(p2.x,p2.y));
	}
	
	public static function hitTestLine2Line(l1p1:Point, l1p2:Point, l2p1:Point, l2p2:Point):Bool
	{
		var q:Float = (l1p1.y - l2p1.y) * (l2p2.x - l2p1.x) - (l1p1.x - l2p1.x) * (l2p2.y - l2p1.y);
		var d:Float = (l1p2.x - l1p1.x) * (l2p2.y - l2p1.y) - (l1p2.y - l1p1.y) * (l2p2.x - l2p1.x);

		if( d == 0 )
		{
			return false;
		}

		var r:Float = q / d;

		q = (l1p1.y - l2p1.y) * (l1p2.x - l1p1.x) - (l1p1.x - l2p1.x) * (l1p2.y - l1p1.y);
		var s:Float = q / d;

		if( r < 0 || r > 1 || s < 0 || s > 1 )
		{
			return false;
		}

		return true;
	}
	
	public static function hitTestLine2Circle(Ax:Float, Ay:Float, Bx:Float, By:Float, Cx:Float, Cy:Float, R:Float):Bool
	{
		var LAB:Float = Math.sqrt((Bx - Ax) * (Bx - Ax) + (By - Ay) * (By - Ay));

		var Dx:Float = (Bx - Ax) / LAB;
		var Dy:Float = (By - Ay) / LAB;
		
		var t:Float = Dx * (Cx - Ax) + Dy * (Cy - Ay); 

		var Ex:Float = t * Dx + Ax;
		var Ey:Float = t * Dy + Ay;

		var LEC:Float = Math.sqrt((Ex - Cx) * (Ex - Cx) + (Ey - Cy) * (Ey - Cy));

		if( LEC < R )
		{
			return true;
		}
		
		return false;
	}
	
}