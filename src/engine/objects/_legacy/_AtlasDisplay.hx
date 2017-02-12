package engine.objects._legacy;
import engine.assets.Textures;
import engine.objects.Entity;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Tilesheet;
import openfl.geom.Point;

/**
 * ...
 * @author TommyX
 */
class AtlasDisplay extends Entity
{

	public var textureAtlas(default, null):Array<Tilesheet>;
	
	public var elementList:Array<Array<Bool>>; //Index matching layerData ID
	public var renderList:Array<Array<Float>>;
	
	private var additive:Array<Bool>; //These 2 are in reversed order than elementList
	private var texture:Array<Int>;
	
	public var textureData(default, null):Map<String,String>; //Layer Name - Texture Name
	public var atlasData(default, null):Map<String,Int>; //Texture Name - Texture ID
	public var elementData(default, null):Map<String,Map<String,Int>>; //Texture Name - Tile Name - Tile ID
	public var layerData(default, null):Map<String,Int>; //Layer Name - Layer ID
	
	private var flag:Int;
	public var flagCount:Int = 9;
	
	public function new(_parentEntity:Entity, _layerData:Array<Array<Dynamic>>, _elementData:Array<Array<Dynamic>>)
	{
		super(_parentEntity);
		
		//layerdata: layer name, texture name, additive
		//elementdata: texture name, tile name, rect, point
		
		//Do not include tile data for textures that aren't used by any layer
		
		textureAtlas = new Array<Tilesheet>();
		elementList = new Array<Array<Bool>>();
		renderList = new Array<Array<Float>>();
		additive = new Array<Bool>();
		texture = new Array<Int>();
		textureData = new Map<String,String>();
		atlasData = new Map<String,Int>();
		elementData = new Map<String,Map<String,Int>>();
		layerData = new Map<String,Int>();
		
		var i:Int = _layerData.length - 1;
		var h:Int = 0;
		for (layer in _layerData) {
			elementList.push([]);
			renderList.push([]);
			layerData.set(layer[0], i);
			if (atlasData.get(layer[1]) == null) {
				atlasData.set(layer[1], h);
				elementData.set(layer[1], new Map<String,Int>());
				texture.push(h);
				h++;
				textureAtlas.push(new Tilesheet(Textures.get(layer[1])));
			}
			else {
				texture.push(atlasData.get(layer[1]));
			}
			textureData.set(layer[0], layer[1]);
			additive.push(layer[2]);
			i--;
		}
		
		for (element in _elementData) {
			if (element[3] == null) {
				element[3] = new Point(element[2].width / 2, element[2].height / 2);
			}
			elementData.get(element[0]).set(element[1], textureAtlas[atlasData.get(element[0])].addTileRect(element[2], element[3]));
		}
		
		var k:Int = 0;
		for (i in 0...NRFDisplay.atlasListBuffer) {
			for (h in elementList){
				h.push(false);
			}
			for (h in renderList) {
				for (k in 0...flagCount){
					h.push(0);
				}
			}
		}
		
	}

	private override function update():Void
	{
		if (visible) {
			graphics.clear();
			var i:Int = renderList.length - 1;
			for (layer in renderList){
				if (layer.length > 0) {
					if (additive[i]) {
						flag = Tilesheet.TILE_BLEND_ADD | Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_RGB | Tilesheet.TILE_ALPHA;
					}
					else {
						flag = Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_RGB | Tilesheet.TILE_ALPHA;
					}
					textureAtlas[texture[i]].drawTiles(graphics, layer, NRFDisplay.atlasSmoothing, flag);
				}
				i--;
			}
		}
	}
	
	public override function addChild(child:DisplayObject):DisplayObject
	{
		return null;
	}
	
}