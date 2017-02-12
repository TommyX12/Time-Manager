package engine.display;

import engine.assets.TextureAtlas;
import engine.objects.AtlasContainer;
import engine.objects.AtlasElement;
import engine.objects.AtlasEntity;
import engine.display.Viewport;
import engine.utils.Util;
import openfl.display.Tilesheet;
import openfl.geom.Point;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.Lib;
import engine.utils.Convert;
import openfl.events.Event;
import openfl.display.BitmapDataChannel;


class AtlasDisplay extends AtlasContainer
{
	public var useSmoothing:Bool;
	public var blendMode:Int;
	public var useTint:Bool;

	public var target:RenderTarget;
	public var viewport:Viewport;
	public var tilesheet:TextureAtlas;
	private var renderList:RenderList;
	public var MB_enabled(default, null):Bool;
	private var MB_tilesheet:TextureAtlas;
	private var MB_target:RenderTarget;
	private var MB_renderList:RenderList;
	public var FX_enabled(default, null):Bool;
	private var FX_target:RenderTarget;
	private var FX_renderList:RenderList;
	public var FX_container:AtlasContainer;
	
	private var t:AtlasTransform = new AtlasTransform();

	public function new(target:RenderTarget, tilesheet:TextureAtlas, ?blendMode:Int)
	{
		this.screen = target.viewport.screen;
		
		super(this);

		stringID = "AtlasDisplay";
		this.target = target;
		target.addDisplay(this);
		this.viewport = target.viewport;
		this.tilesheet = tilesheet;
		useSmoothing = NRFDisplay.atlasSmoothing;
		this.blendMode = blendMode;
		useTint = true;
		
		MB_enabled = false;
		FX_enabled = false;

		renderList = new RenderList();
	}

	public function render()
	{
		var _blendMode:Int = -1;
		if (blendMode == AtlasBlendMode.ADD) _blendMode = Tilesheet.TILE_BLEND_ADD;
		if (blendMode == AtlasBlendMode.SUBTRACT) _blendMode = Tilesheet.TILE_BLEND_SUBTRACT;
		if (blendMode == AtlasBlendMode.SCREEN) _blendMode = Tilesheet.TILE_BLEND_SCREEN;
		if (blendMode == AtlasBlendMode.MULTIPLY) _blendMode = Tilesheet.TILE_BLEND_MULTIPLY;
		AtlasTransform.cameraX = screen.cameraPos.x;
		AtlasTransform.cameraY = screen.cameraPos.y;
		AtlasTransform.cameraDepth = screen.cameraDepth;
		AtlasTransform.cameraZoom = screen.cameraZoom;
		AtlasTransform.cameraSin = -Math.sin(Convert.rad(screen.cameraRotation));
		AtlasTransform.cameraCos = Math.cos(Convert.rad(screen.cameraRotation));
		renderList.begin(true, true, useTint, _blendMode);
		renderGroup(this, 0);
		renderList.end();
		tilesheet.drawTiles(target.graphics, renderList.list, useSmoothing, renderList.flags);
		if (MB_enabled && NRFDisplay.motionBlur) {
			MB_renderList.begin(true, true, true, -1);
			MB_renderGroup(this, 0);
			MB_renderList.end();
			MB_tilesheet.drawTiles(MB_target.graphics, MB_renderList.list, useSmoothing, MB_renderList.flags);
		}
		if (FX_enabled && NRFDisplay.fxMap) {
			FX_renderList.begin(true, true, true, -1);
			FX_renderGroup(FX_container, 0);
			FX_renderList.end();
			tilesheet.drawTiles(FX_target.graphics, FX_renderList.list, useSmoothing, FX_renderList.flags);
		}
	}

	private function renderGroup(group:AtlasContainer, index:Int)
	{
		var list = renderList.list;
		var fields = renderList.fields;
		var offsetRGB = renderList.offsetRGB;
		var offsetTransform = renderList.offsetTransform;
		var offsetAlpha = renderList.offsetAlpha;

		if (group.parent == null) {
			if (group.transformMode == AtlasTransformMode.LOCAL) group.transformMode = AtlasTransformMode.GLOBAL;
		}
		if (group.transformMode == AtlasTransformMode.GLOBAL) {
			group.globalTransform.transform_global(group.localTransform); 
			t = group.globalTransform;
		}
		else if (group.transformMode == AtlasTransformMode.LOCAL) {
			group.globalTransform.transform_local(group.localTransform, group.parent.globalTransform); 
			t = group.globalTransform;
		}
		else if (group.transformMode == AtlasTransformMode.PARALLAX) {
			group.globalTransform.transform_parallax(group.localTransform, group.depth); 
			t = group.globalTransform;
		}
		else if (group.transformMode == AtlasTransformMode.PARALLAX_NOSCALE) {
			group.globalTransform.transform_parallax_noscale(group.localTransform, group.depth); 
			t = group.globalTransform;
		}
		
		var n = group.numChildren;
		for(i in 0...n)
		{
			var child = group.children[i];
			
			if (child.visible == false) continue;
			
			var group:AtlasContainer = cast child;

			if (group != null) 
			{
				index = renderGroup(group, index);
			}
			else 
			{
				var sprite:AtlasEntity = cast child;
				
				if (sprite.transformMode == AtlasTransformMode.GLOBAL) {
					sprite.globalTransform.transform_global(sprite.localTransform); 
					t = sprite.globalTransform;
				}
				else if (sprite.transformMode == AtlasTransformMode.LOCAL) {
					sprite.globalTransform.transform_local(sprite.localTransform, sprite.parent.globalTransform); 
					t = sprite.globalTransform;
				}
				else if (sprite.transformMode == AtlasTransformMode.PARALLAX) {
					sprite.globalTransform.transform_parallax(sprite.localTransform, sprite.depth); 
					t = sprite.globalTransform;
				}
				else if (sprite.transformMode == AtlasTransformMode.PARALLAX_NOSCALE) {
					sprite.globalTransform.transform_parallax_noscale(sprite.localTransform, sprite.depth); 
					t = sprite.globalTransform;
				}
				
				if (t.alpha <= 0.0) continue;
				
				list[index+2] = sprite.indice;

				list[index] = t.tx;
				list[index+1] = t.ty;
				list[index+offsetTransform] = t.a;
				list[index+offsetTransform+1] = t.b;
				list[index+offsetTransform+2] = t.c;
				list[index+offsetTransform+3] = t.d;

				if (offsetRGB > 0) {
					list[index+offsetRGB] = sprite.r*0.8*sprite.luminance;
					list[index+offsetRGB+1] = sprite.g*0.8*sprite.luminance;
					list[index+offsetRGB+2] = sprite.b*0.8*sprite.luminance;
				}
				list[index+offsetAlpha] = sprite.transformMode == AtlasTransformMode.PREVIOUS ? t.alpha * sprite.alpha : t.alpha;
				index += fields;
			}
		}
		renderList.index = index;
		return index;
	}
	
	private function MB_renderGroup(group:AtlasContainer, index:Int)
	{
		var list = MB_renderList.list;
		var fields = MB_renderList.fields;
		var offsetRGB = renderList.offsetRGB;
		var offsetTransform = renderList.offsetTransform;
		var offsetAlpha = renderList.offsetAlpha;
		
		if (group.transformMode != AtlasTransformMode.PREVIOUS){
			t = group.globalTransform;
		}
		
		var n = group.numChildren;
		for(i in 0...n)
		{
			var child = group.children[i];
			
			if (child.visible == false || child.motionBlur == false) continue;
			
			var group:AtlasContainer = cast child;

			if (group != null) 
			{
				index = MB_renderGroup(group, index);
			}
			else 
			{
				var sprite:AtlasEntity = cast child;
				
				if (sprite.transformMode != AtlasTransformMode.PREVIOUS){
					t = sprite.globalTransform;
				}
				
				if (t.alpha <= 0.0) continue;
				
				if (sprite._lastX == -9999) sprite._lastX = t.tx;
				if (sprite._lastY == -9999) sprite._lastY = t.ty;
				
				list[index + 2] = sprite.indice;
				
				list[index] = t.tx;
				list[index+1] = t.ty;
				list[index+offsetTransform] = t.a;
				list[index+offsetTransform+1] = t.b;
				list[index+offsetTransform+2] = t.c;
				list[index+offsetTransform+3] = t.d;
				
				var velocityX:Float = t.tx - sprite._lastX;
				var velocityY:Float = t.ty - sprite._lastY;
				
				list[index + offsetRGB] = Math.abs(velocityX) * NRFDisplay.motionBlurIntensity;
				list[index + offsetRGB + 1] = Math.abs(velocityY) * NRFDisplay.motionBlurIntensity;
				list[index + offsetRGB + 2] = velocityX * velocityY < 0 ? 1 : 0;
				
				sprite._lastX = t.tx;
				sprite._lastY = t.ty;
				
				list[index+offsetAlpha] = sprite.alpha;
				index += fields;
			}
		}
		MB_renderList.index = index;
		return index;
	}
	
	private function FX_renderGroup(group:AtlasContainer, index:Int)
	{
		var list = FX_renderList.list;
		var fields = FX_renderList.fields;
		var offsetRGB = renderList.offsetRGB;
		var offsetTransform = renderList.offsetTransform;
		var offsetAlpha = renderList.offsetAlpha;
		
		if (group.transformMode != AtlasTransformMode.PREVIOUS){
			t = group.globalTransform;
		}
		
		var n = group.numChildren;
		for(i in 0...n)
		{
			var child = group.children[i];
			
			if (child.visible == false) continue;
			
			var group:AtlasContainer = cast child;

			if (group != null) 
			{
				index = MB_renderGroup(group, index);
			}
			else 
			{
				var sprite:AtlasEntity = cast child;
				
				if (sprite.transformMode != AtlasTransformMode.PREVIOUS){
					t = sprite.globalTransform;
				}
				
				if (t.alpha <= 0.0) continue;
				
				if (sprite._lastX == -9999) sprite._lastX = t.tx;
				if (sprite._lastY == -9999) sprite._lastY = t.ty;
				
				list[index + 2] = sprite.indice;
				
				list[index] = t.tx;
				list[index+1] = t.ty;
				list[index+offsetTransform] = t.a;
				list[index+offsetTransform+1] = t.b;
				list[index+offsetTransform+2] = t.c;
				list[index + offsetTransform + 3] = t.d;
				
				list[index + offsetRGB] = sprite.r;
				list[index + offsetRGB + 1] = sprite.g;
				list[index + offsetRGB + 2] = sprite.b;
				
				list[index+offsetAlpha] = sprite.alpha;
				index += fields;
			}
		}
		FX_renderList.index = index;
		return index;
	}
	
	public override function update()
	{
		updateGroup(this);
		updateChildrenGrid();
	}
	
	public function updateGroup(group:AtlasContainer)
	{
		var n = group.numChildren;
		for(i in 0...n)
		{
			var child:AtlasElement = group.children[i];
			
			if (child != null){
				child.backgroundUpdate();
				if (!screen.paused) {
					child.internalUpdate();
					if (child.animated) child.step();
					child.update();
				}
			}
			
			var group:AtlasContainer = cast child;

			if (group != null) 
			{
				group.updateChildrenGrid();
				updateGroup(group);
			}
			
		}
	}
	
	public function enableMotionBlur(target:RenderTarget):Void
	{
		if (NRFDisplay.motionBlur){
			MB_target = target;
			MB_renderList = new RenderList();
			MB_enabled = true;
			var image:BitmapData = new BitmapData(tilesheet.img.width, tilesheet.img.height);
			image.copyChannel(tilesheet.img, image.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.RED);
			image.copyChannel(tilesheet.img, image.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
			image.copyChannel(tilesheet.img, image.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.BLUE);
			image.copyChannel(tilesheet.img, image.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			MB_tilesheet = new TextureAtlas(image, tilesheet.scale);
			for (i in 0...tilesheet.defs.length) {
				MB_tilesheet.addDefinition(tilesheet.defs[i], tilesheet.sizes[i], tilesheet.rects[i], tilesheet.centers[i]);
			}
		}
	}
	
	public function enableFX(target:RenderTarget):Void
	{
		FX_target = target;
		FX_renderList = new RenderList();
		FX_enabled = true;
		FX_container = new AtlasContainer(this);
	}
}