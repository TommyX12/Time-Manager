package engine.objects;

import engine.display.AdvancedViewport;
import engine.display.AtlasDisplay;
import engine.display.AtlasTransformMode;

/**
 * ...
 * @author TommyX
 */
class AtlasGodRays extends AtlasEntity
{
	
	public var radius1:Float;
	public var radius2:Float;
	public var amount:Float;

	public function new(layer:AtlasDisplay) 
	{
		super(layer, null);
		stringID = "AtlasEntity";
		radius1 = 200;
		radius2 = 600;
		amount = 1;
	}
	
	override public function update():Void
	{
		this.visible = false;
		
		if (this.transformMode == AtlasTransformMode.GLOBAL) this.globalTransform.transform_global(this.localTransform);
		else if (this.transformMode == AtlasTransformMode.LOCAL) this.globalTransform.transform_local(this.localTransform, this.parent.globalTransform);
		else if (this.transformMode == AtlasTransformMode.PARALLAX) this.globalTransform.transform_parallax(this.localTransform, this.depth);
		else if (this.transformMode == AtlasTransformMode.PARALLAX_NOSCALE) this.globalTransform.transform_parallax_noscale(this.localTransform, this.depth);
		
		var advViewport:AdvancedViewport = cast this.layer.viewport;

		if (advViewport != null){
			advViewport.godRaysX = this.globalTransform.tx;
			advViewport.godRaysY = this.globalTransform.ty;
			advViewport.godRaysRadius1 = this.radius1 * this.screen.cameraZoom;
			advViewport.godRaysRadius2 = this.radius2 * this.screen.cameraZoom;
			advViewport.godRaysAmount = this.amount;
		}
	}
	
}