package engine.shaders;

import engine.display.AdvancedViewport;
import engine.utils.Convert;
import openfl.display.Sprite;
import openfl.gl.*;
import openfl.display.OpenGLView;
import openfl.Lib;
import flash.geom.*;
import engine.display.RenderTarget;

class SourceRenderPass extends OpenGLView{
    var framebuffer:GLFramebuffer;
	private var viewport:AdvancedViewport;
	public var source:RenderTarget;
	public var alphaBlending:Bool;
	public var resolution:Float;
	
	public function new(viewport:AdvancedViewport, source:RenderTarget, destFrameBuffer:Int, alphaBlending:Bool)
	{
        super();
		this.viewport = viewport;
		this.source = source;
        this.framebuffer = viewport.dest[destFrameBuffer];
		this.resolution = viewport.texResolution[destFrameBuffer];
		this.alphaBlending = alphaBlending;
		
		//this.render = _render;
    }
 
	//public function _render() {
    override public function render(rect : Rectangle) {
		/*
		var cw = Lib.current.stage.stageWidth;
		var ch = Lib.current.stage.stageHeight;
		var sf = 0.0;
		var sx = 0.0;
		var sy = 0.0;
		if (cw / ch > NRFDisplay.rawWidth / NRFDisplay.rawHeight) {
			sf = ch / NRFDisplay.rawHeight;
			sx = (cw - NRFDisplay.rawWidth * sf) / 2 / sf;
			sy = 0;
		}
		else {
			sf = cw / NRFDisplay.rawWidth;
			sx = 0;
			sy = (ch - NRFDisplay.rawHeight * sf) / 2 / sf;
		}
		
		var dx = -sx;
		var dy = sy + NRFDisplay.rawHeight;
		source.x = dx * (1 - resolution);
		source.y = dy * (1 - resolution);
		source.scaleX = source.scaleY = resolution;
		*/
		
        GL.bindFramebuffer(GL.FRAMEBUFFER, this.framebuffer);

        GL.viewport (0, 0, Convert.int(NRFDisplay.currentWidth*resolution), Convert.int(NRFDisplay.currentHeight*resolution));
        GL.clearColor (0.0, 0.0, 0.0, 0.0);
		if (!alphaBlending){
			GL.clear (GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
		}

        GL.disable( GL.DEPTH_TEST );
    }
}