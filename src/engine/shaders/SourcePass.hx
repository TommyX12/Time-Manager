package engine.shaders;

import engine.display.RenderTarget;
import openfl.display.Sprite;
import openfl.gl.GLFramebuffer;
import engine.display.AdvancedViewport;

/**
 * ...
 * @author TommyX
 */
class SourcePass extends Sprite
{
	public var source:RenderTarget;
	public var pass:SourceRenderPass;
	
	public function new(viewport:AdvancedViewport, sourceSprite:RenderTarget, destFrameBuffer:Int, alphaBlending:Bool=false) 
	{
		super();
		source = sourceSprite;
		pass = new SourceRenderPass(viewport, sourceSprite, destFrameBuffer, alphaBlending);
		this.addChild(pass);
		this.addChild(source);
	}
	
}