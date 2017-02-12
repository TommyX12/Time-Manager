package engine.objects._legacy;
import engine.display.Screen;
import engine.display.AtlasDisplay;
import engine.objects.AtlasContainer;
import engine.utils.Convert;
import engine.utils.Util;
import openfl.geom.Rectangle;
import openfl.geom.Point;

/**
 * ...
 * @author TommyX
 */
class AtlasElement
{

	public var parent:AtlasContainer;
	
	public var screen:Screen;
	
	public var registered:Bool;
	@:isVar public var globalTransform(default, set):Bool;

	public var x:Float;
	public var y:Float;
	public var scale:Float;
	public var rotation:Float;
	public var alpha:Float;
	public var visible:Bool;
	@:isVar public var brightness(default, set):Float = 1;
	@:isVar public var tintR(default, set):Float = 1;
	@:isVar public var tintG(default, set):Float = 1;
	@:isVar public var tintB(default, set):Float = 1;
	
	public var parallaxEnabled(default, null):Bool;
	public var autoScaleEnabled(default, null):Bool;
	public var prlX:Float;
	public var prlY:Float;
	public var prlScale:Float;
	public var prlScaleMultiplier:Float;
	public var prlDepth:Float;
	
	public var globalCoord(default, null):Point;
	public var globalScale(default, null):Float;
	public var globalRotation(default, null):Float;
	public var globalAlpha(default, null):Float;
	
	//Further Animation Support, caching all tile ids and radiuss and center offsets
	//Further scaleXY and mirroring support from tileLayer
	
	public var atlasDisplay(default, null):AtlasDisplay;
	public var flagCount(default, null):Int;
	public var layerName(default, null):String;
	public var layerID(default, null):Int;
	public var textureName(default, null):String;
	public var textureID(default, null):Int;
	@:isVar public var tileName(default, set):String;
	@:isVar public var tileID(default, set):Int;
	public var tileRect(default, null):Rectangle;
	public var tileRadius(default, null):Float;
	public var tileCenter(default, null):Point;
	public var tileCenterRadius(default, null):Float;
	public var elementList(default, null):Array<Bool>;
	public var renderList(default, null):Array<Float>;
	public var renderIndex(default, null):Int;
	
	function set_globalTransform(_globalTransform:Bool)
	{
		if (_globalTransform) {
			disableParallax();
		}
		return globalTransform = _globalTransform;
	}
	
	function set_tileName(_tileName:String)
	{
		tileID = atlasDisplay.elementData.get(textureName).get(_tileName);
		return tileName = _tileName;
	}
	
	function set_tileID(_tileID:Int)
	{
		tileRect = atlasDisplay.textureAtlas[textureID].getTileRect(_tileID);
		tileRadius = Util.getDistance(tileRect.width / 2, tileRect.height / 2);
		tileCenter = atlasDisplay.textureAtlas[textureID].getTileCenter(_tileID).clone();
		tileCenter.x -= tileRect.width / 2;
		tileCenter.y -= tileRect.height / 2;
		tileCenterRadius = tileRadius + Util.getDistance(tileCenter.x, tileCenter.y);
		return tileID = _tileID;
	}
	
	function set_brightness(_brightness:Float)
	{
		if (registered) {
			renderList[flagCount * renderIndex + 5] = tintR * _brightness;
			renderList[flagCount * renderIndex + 6] = tintG * _brightness;
			renderList[flagCount * renderIndex + 7] = tintB * _brightness;
		}
		return brightness = _brightness;
	}
	
	function set_tintR(_tintR:Float)
	{
		if (registered) {
			renderList[flagCount * renderIndex + 5] = _tintR * brightness;
		}
		return tintR = _tintR;
	}
	
	function set_tintG(_tintG:Float)
	{
		if (registered) {
			renderList[flagCount * renderIndex + 6] = _tintG * brightness;
		}
		return tintG = _tintG;
	}
	
	function set_tintB(_tintB:Float)
	{
		if (registered) {
			renderList[flagCount * renderIndex + 7] = _tintB * brightness;
		}
		return tintB = _tintB;
	}
	
	public function new(_parent:AtlasContainer, _atlasDisplay:AtlasDisplay, _layerName:String, _tileName:String, _globalTransform:Bool = false, _x:Float = 0, _y:Float = 0, _scale:Float = 1, _rotation:Float = 0, _alpha:Float = 1, _brightness:Float = 1, _tintR:Float = 1, _tintG:Float = 1, _tintB:Float = 1, _visible:Bool = true)
	{
		parent = _parent;
		
		screen = _parent.screen;
		
		registered = false;
		
		renderIndex = -1;
		
		globalTransform = _globalTransform;
		
		x = _x;
		y = _y;
		scale = _scale;
		rotation = _rotation;
		alpha = _alpha;
		visible = _visible;
		brightness = _brightness;
		tintR = _tintR;
		tintG = _tintG;
		tintB = _tintB;
		
		parallaxEnabled = false;
		prlScaleMultiplier = 1;
		
		atlasDisplay = _atlasDisplay;
		flagCount = atlasDisplay.flagCount;
		layerName = _layerName;
		layerID = atlasDisplay.layerData.get(layerName);
		textureName = atlasDisplay.textureData.get(layerName);
		textureID = atlasDisplay.atlasData.get(textureName);
		tileName = _tileName;
		
		elementList = atlasDisplay.elementList[layerID];
		renderList = atlasDisplay.renderList[layerID];
		
	}
	
	public function uploadData():Void
	{
		backgroundUpdate();
		if (screen.paused == false) {
			update();
		}
		parallaxUpdate();
		if (visible && parent.globalVisible && screen.visible) {
			if (globalTransform){
				globalCoord = parent.localToGlobal(new Point(x, y));
				globalScale = scale * parent.globalScale;
				globalRotation = rotation + parent.globalRotation;
				globalAlpha = alpha * parent.globalAlpha;
			}
			if (onScreen()) {
				register();
				if (globalTransform){
					renderList[flagCount * renderIndex + 2] = tileID;
					renderList[flagCount * renderIndex + 0] = (globalCoord.x - NRFDisplay.stageShiftX) / NRFDisplay.scaleFactor;
					renderList[flagCount * renderIndex + 1] = (globalCoord.y - NRFDisplay.stageShiftY) / NRFDisplay.scaleFactor;
					renderList[flagCount * renderIndex + 3] = globalScale;
					renderList[flagCount * renderIndex + 4] = Convert.rad(globalRotation);
					renderList[flagCount * renderIndex + 8] = globalAlpha;
				}
				else {
					renderList[flagCount * renderIndex + 2] = tileID;
					renderList[flagCount * renderIndex + 0] = x;
					renderList[flagCount * renderIndex + 1] = y;
					renderList[flagCount * renderIndex + 3] = scale;
					renderList[flagCount * renderIndex + 4] = Convert.rad(rotation);
					renderList[flagCount * renderIndex + 8] = alpha;
				}
				//add multi res
			}
			else {
				unregister();
			}
		}
		else {
			unregister();
		}
	}
	
	private function register():Void
	{
		if (registered == false) {
			var index:Int = 0;
			for (element in elementList) {
				if (element == false){
					renderIndex = index;
					elementList[index] = true;
					registered = true;
					break;
				}
				index++;
			}
			if (registered == false){
				renderIndex = elementList.length;
				elementList.push(true);
				for (i in 0...atlasDisplay.flagCount) {
					renderList.push(0);
				}
				registered = true;
			}
			renderList[flagCount * renderIndex + 5] = tintR * brightness;
			renderList[flagCount * renderIndex + 6] = tintG * brightness;
			renderList[flagCount * renderIndex + 7] = tintB * brightness;
		}
	}
	
	private function unregister():Void
	{
		if (registered) {
			elementList[renderIndex] = false;
			for (i in 0...atlasDisplay.flagCount) {
				renderList[flagCount * renderIndex + i] = 0;
			}
			while (elementList.length > NRFDisplay.atlasListBuffer && elementList[elementList.length - 1] == false) {
				elementList.pop();
				for (i in 0...atlasDisplay.flagCount) {
					renderList.pop();
				}
			}
			renderIndex = -1;
			registered = false;
		}
	}
	
	private function update():Void
	{
		rotation++;
		//override
	}
	
	private function backgroundUpdate():Void
	{
		//override
	}
	
	public function added():Void
	{
		//override
	}
	
	public function removed():Void
	{
		//override
	}
	
	public function getPrlX(_x:Float):Float
	{
		return (_x - NRFDisplay.centerWidth) * prlDepth + screen.viewCenterX;
	}
	
	public function getPrlY(_y:Float):Float
	{
		return (_y - NRFDisplay.centerHeight) * prlDepth + screen.viewCenterY;
	}
	
	public function getPrlScale(_scale:Float):Float
	{
		return _scale * prlDepth / prlScaleMultiplier;
	}
	
	public function enableParallax(depth:Float, autoScale:Bool = false):Void
	{
		if (globalTransform == false) {
			parallaxEnabled = true;
			autoScaleEnabled = autoScale;
			prlDepth = depth;
			prlX = getPrlX(x);
			prlY = getPrlY(y);
			prlScale = scale;
		}
	}
	
	public function disableParallax():Void
	{
		parallaxEnabled = false;
	}
	
	private function parallaxUpdate():Void
	{
		if (parallaxEnabled){
			x = (prlX - screen.viewCenterX) / prlDepth + NRFDisplay.centerWidth;
			y = (prlY - screen.viewCenterY) / prlDepth + NRFDisplay.centerHeight;
			if (autoScaleEnabled) {
				scale = prlScale / prlDepth * prlScaleMultiplier;
			}
		}
	}
	
	public function remove():Void
	{
		this.parent.removeElement(this);
	}
	
	public function onScreen():Bool
	{
		if (globalTransform){
			if (globalCoord.x + (tileCenterRadius) * globalScale * NRFDisplay.scaleFactor > 0 && globalCoord.x - (tileCenterRadius) * globalScale * NRFDisplay.scaleFactor < NRFDisplay.currentWidth && globalCoord.y + (tileCenterRadius) * globalScale * NRFDisplay.scaleFactor > 0 && globalCoord.y - (tileCenterRadius) * globalScale * NRFDisplay.scaleFactor < NRFDisplay.currentHeight) {
				return true;
			}
		}
		else {
			if (x + NRFDisplay.localStageShiftX + (tileCenterRadius) * scale > 0 && x + NRFDisplay.localStageShiftX - (tileCenterRadius) * scale < NRFDisplay.currentWidth / NRFDisplay.scaleFactor && y + NRFDisplay.localStageShiftY + (tileCenterRadius) * scale > 0 && y + NRFDisplay.localStageShiftY - (tileCenterRadius) * scale < NRFDisplay.currentHeight / NRFDisplay.scaleFactor) {
				return true;
			}
		}
		return false;
	}
	
	public function centerPos(global:Bool = false):Void
	{
		if (global) {
			if (parallaxEnabled) {
				prlX = getPrlX(NRFDisplay.currentWidth / 2);
				prlY = getPrlY(NRFDisplay.currentHeight / 2);
			}
			else {
				if (this.parent != null) {
					var point:Point = this.parent.globalToLocal(new Point(NRFDisplay.currentWidth / 2, NRFDisplay.currentHeight / 2));
					x = point.x;
					y = point.y;
				}
			}
		}
		else {
			if (parallaxEnabled) {
				prlX = 0;
				prlY = 0;
			}
			else {
				x = NRFDisplay.centerWidth;
				y = NRFDisplay.centerHeight;
			}
		}
	}
	
}