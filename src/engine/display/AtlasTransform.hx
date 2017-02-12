package engine.display;

/**
 * ...
 * @author TommyX
 */
class AtlasTransform
{
	public static var cameraX(null, default):Float = 0;
	public static var cameraY(null, default):Float = 0;
	public static var cameraDepth(null, default):Float = 0;
	public static var cameraZoom(null, default):Float = 1;
	public static var cameraSin(null, default):Float = 0;
	public static var cameraCos(null, default):Float = 1;
	
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
	public var tx:Float;
	public var ty:Float;
	public var alpha:Float;
	
	private var centerX:Float;
	private var centerY:Float;

	public function new() 
	{
		a = 1;
		b = 0;
		c = 0;
		d = 1;
		tx = 0;
		ty = 0;
		alpha = 1;
		
		centerX = NRFDisplay.centerWidth;
		centerY = NRFDisplay.centerHeight;
	}
	
	public function transform_global(child:AtlasTransform):Void
	{
		this.a = child.a;
		this.b = child.b;
		this.c = child.c;
		this.d = child.d;
		this.tx = child.tx;
		this.ty = child.ty;
		this.alpha = child.alpha;
	}
	
	public function transform_local(child:AtlasTransform, parent:AtlasTransform):Void
	{
		var a00:Float = child.a;
		var a01:Float = child.b;
		var a10:Float = child.c;
		var a11:Float = child.d;
		var atx:Float = child.tx;
		var aty:Float = child.ty;
		var b00:Float = parent.a;
		var b01:Float = parent.b;
		var b10:Float = parent.c;
		var b11:Float = parent.d;
		var btx:Float = parent.tx;
		var bty:Float = parent.ty;
		
		this.a = a00 * b00 + a01 * b10;
		this.b = a00 * b01 + a01 * b11;
		this.c = a10 * b00 + a11 * b10;
		this.d = a10 * b01 + a11 * b11;
		this.tx = atx * b00 + aty * b10 + btx;
		this.ty = atx * b01 + aty * b11 + bty;
		this.alpha = parent.alpha * child.alpha;
	}
	
	public function transform_parallax(child:AtlasTransform, childDepth:Float):Void
	{
		var depth:Float = 1 / (childDepth - cameraDepth) * cameraZoom;
		
		this.a = (child.a * cameraCos + child.b * -cameraSin) * depth;
		this.b = (child.a * cameraSin + child.b * cameraCos) * depth;
		this.c = (child.c * cameraCos + child.d * -cameraSin) * depth;
		this.d = (child.c * cameraSin + child.d * cameraCos) * depth;
		this.tx = ((child.tx - cameraX) * cameraCos - (child.ty - cameraY) * cameraSin) * depth + centerX;
		this.ty = ((child.tx - cameraX) * cameraSin + (child.ty - cameraY) * cameraCos) * depth + centerY;
		this.alpha = child.alpha * Math.min(Math.max(10 / depth * cameraZoom - 2, 0), 1);
	}
	
	public function transform_parallax_noscale(child:AtlasTransform, childDepth:Float):Void
	{
		var depth:Float = 1 / (childDepth - cameraDepth);
		
		this.a = (child.a * cameraCos + child.b * -cameraSin) * cameraZoom;
		this.b = (child.a * cameraSin + child.b * cameraCos) * cameraZoom;
		this.c = (child.c * cameraCos + child.d * -cameraSin) * cameraZoom;
		this.d = (child.c * cameraSin + child.d * cameraCos) * cameraZoom;
		this.tx = ((child.tx - cameraX) * cameraCos - (child.ty - cameraY) * cameraSin) * depth * cameraZoom + centerX;
		this.ty = ((child.tx - cameraX) * cameraSin + (child.ty - cameraY) * cameraCos) * depth * cameraZoom + centerY;
		this.alpha = child.alpha;
	}
	
}