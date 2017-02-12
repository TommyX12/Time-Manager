package engine.display;

import engine.shaders.source.*;
import engine.shaders.*;
import engine.utils.*;
import engine.assets.AssetsManager;
import openfl.events.Event;
import openfl.gl.*;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.utils.UInt8Array;

class AdvancedViewport extends Viewport {
	private var numTexture:Int = 18;
	public var src(default, null):Array<GLTexture>;
	public var dest(default, null):Array<GLFramebuffer>;
	private var renderBuffer(default, null):Array<GLRenderbuffer>;
	private var backBuffer:Int = 0;
	private var srcMap:Int = 1;
	private var tempMap1:Int = 2;
	private var mainMap1:Int = 2;
	private var mainMap2:Int = 1;
	private var MBMap1:Int = 3;
	private var MBMap2:Int = 4;
	private var Map0:Int = 5;
	private var Map1:Int = 6;
	private var MapA:Int = 7;
	private var MapB:Int = 8;
	private var Map2A:Int = 9;
	private var Map2B:Int = 10;
	private var Map3A:Int = 11;
	private var Map3B:Int = 12;
	private var Map4A:Int = 13;
	private var Map4B:Int = 14;
	private var Map8A:Int = 15;
	private var Map8B:Int = 16;
	private var Map16A:Int = 17;
	private var Map16B:Int = 18;
	private var dirtTex:Int = 19;
	private var noiseTex:Int = 20;
	public var texResolution(default, null):Array<Float> = [
		1,//backbuffer
		1,//srcmap
		1,//tempmap1
		NRFDisplay.motionBlurRes,//mbmap1
		NRFDisplay.motionBlurRes,//mbmap2
		0.35,//map0
		0.25,//map1
		0.35,//mapa
		0.35,//mapb
		0.5,//map2a
		0.5,//map2b
		0.35,//map3a
		0.35,//map3b
		0.25,//map4a
		0.25,//map4b
		0.125,//map8a
		0.125,//map8b
		0.0625,//map16a
		0.0625,//map16b
	];

	public var background:RenderTarget;
    public var fx:RenderTarget;
	public var motion:RenderTarget;
	public var overlay:RenderTarget;
    
    private var fxscrollPos:Vec2D;
    private var fxscrollPosLF:Vec2D;
	
	public var param0:Array<Dynamic> = [UniformType.FLOAT, [0]];
	public var param1:Array<Dynamic> = [UniformType.FLOAT, [0]];
	public var param2:Array<Dynamic> = [UniformType.FLOAT, [0]];
	public var param3:Array<Dynamic> = [UniformType.FLOAT, [0]];
	
    public var fxDepth = 1;
	public var godRaysX:Float = 0;
	public var godRaysY:Float = NRFDisplay.rawHeight;
	public var godRaysAmount:Float = 0;
	public var godRaysRadius1:Float = 200;
	public var godRaysRadius2:Float = 600;
	
	private var postBlurPass:RenderPass;
	private var postBlur2Pass:RenderPass;
	public var postBlurRadius:Float = 0;

	public function new(screen:Screen){
		super(screen);
	}
	
	private override function initialize():Void
	{
		background = new RenderTarget(this);
        fx = new RenderTarget(this, true);
		motion = new RenderTarget(this, true);
		overlay = new RenderTarget(this);
        
		/*
		this.addChild(background);
		this.addChild(main);
		this.addChild(fx);
		this.addChild(overlay);
		//*/
		
		///*
        fxscrollPos = new Vec2D().copy(screen.getParallax(NRFDisplay.centerPos, fxDepth));
        fxscrollPosLF = fxscrollPos.clone();
		
 		initializeFrameBuffer();
		
		Lib.current.stage.addEventListener(Event.RESIZE, resizeFrameBuffer);
		
		this.addChild(new SourcePass(this, main, srcMap, false));
        
		if (NRFDisplay.fxMap){
			this.addChild(new UniformPass(fxUniform));
			this.addChild(new RenderPass(this, [Map2A], Map2B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, FXShader.fxblurx)));
			this.addChild(new RenderPass(this, [Map2B], Map2A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, FXShader.fxblury)));
			this.addChild(new SourcePass(this, fx, Map2A, true));
			this.addChild(new RenderPass(this, [Map2A], srcMap, ShaderBlendMode.ALPHA, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, TextureShader.tex)));
			this.addChild(new UniformPass(fxClear));
		}
		else {
			this.addChild(new SourcePass(this, fx, srcMap, true));
		}
		
		this.addChild(new SourcePass(this, background, tempMap1, false));
		
		if (NRFDisplay.godRays) {
			this.addChild(new UniformPass(godRaysUniform));
			this.addChild(new RenderPass(this, [tempMap1, srcMap], Map4A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, GodRaysShader.godraysprepass)));
			
			this.addChild(new RenderPass(this, [Map4A], Map4B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, GodRaysShader.godrays)));
			this.addChild(new RenderPass(this, [Map4B], Map1, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, GodRaysShader.godrays)));
		}
		
		this.addChild(new RenderPass(this, [srcMap], tempMap1, ShaderBlendMode.ALPHA, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, TextureShader.tex)));
		
		if (NRFDisplay.hdr) {
			this.addChild(new RenderPass(this, [tempMap1], MapA, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloomprepass)));
			this.addChild(new RenderPass(this, [tempMap1], MapB, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.streakprepass)));
			
			this.addChild(new RenderPass(this, [MapA], Map4A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom1x)));
			this.addChild(new RenderPass(this, [Map4A], Map4B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom1y)));
			this.addChild(new RenderPass(this, [Map4B], Map4A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom1x)));
			this.addChild(new RenderPass(this, [Map4A], Map4B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom1y)));
			this.addChild(new RenderPass(this, [Map4B], Map0, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, TextureShader.tex)));
			
			this.addChild(new RenderPass(this, [MapB], Map4A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.streak1)));
			this.addChild(new RenderPass(this, [Map4A], Map4B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.streak2)));
			this.addChild(new RenderPass(this, [Map4B], Map0, ShaderBlendMode.ADD, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, TextureShader.tex)));
			
			this.addChild(new RenderPass(this, [MapA], Map3A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom2x)));
			this.addChild(new RenderPass(this, [Map3A], Map3B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom2y)));
			this.addChild(new RenderPass(this, [Map3B], Map3A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom2x)));
			this.addChild(new RenderPass(this, [Map3A], Map3B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom2y)));
			this.addChild(new RenderPass(this, [Map3B], Map0, ShaderBlendMode.SCREEN, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, TextureShader.tex)));
			
			this.addChild(new RenderPass(this, [MapA], Map16A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom3x)));
			this.addChild(new RenderPass(this, [Map16A], Map16B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom3y)));
			this.addChild(new RenderPass(this, [Map16B], Map16A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom3x)));
			this.addChild(new RenderPass(this, [Map16A], Map16B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom3y)));
			this.addChild(new RenderPass(this, [Map16B], Map0, ShaderBlendMode.SCREEN, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, TextureShader.tex)));
			
			this.addChild(new RenderPass(this, [MapA], Map4A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom4x)));
			this.addChild(new RenderPass(this, [Map4A], Map4B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom4y)));
			this.addChild(new RenderPass(this, [Map4B], Map4A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom4x)));
			this.addChild(new RenderPass(this, [Map4A], Map4B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom4y)));
			this.addChild(new RenderPass(this, [Map4B], Map0, ShaderBlendMode.SCREEN, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, TextureShader.tex)));
			
			this.addChild(new RenderPass(this, [MapA], Map8A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom5x)));
			this.addChild(new RenderPass(this, [Map8A], Map8B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom5y)));
			this.addChild(new RenderPass(this, [Map8B], Map8A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom5x)));
			this.addChild(new RenderPass(this, [Map8A], Map8B, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, HDRShader.bloom5y)));
			this.addChild(new RenderPass(this, [Map8B], Map0, ShaderBlendMode.SCREEN, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, TextureShader.tex)));
		}

		if (NRFDisplay.motionBlur) {
			this.addChild(new SourcePass(this, motion, MBMap1, false));
			this.addChild(new RenderPass(this, [MBMap1], MBMap2, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, MotionBlurShader.motionblurprepass)));
			this.addChild(new RenderPass(this, [mainMap1, MBMap2], mainMap2, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, MotionBlurShader.motionblur)));
			this.addChild(new UniformPass(motionClear));
			mainMap1 = mainMap1 == srcMap ? tempMap1 : srcMap;
			mainMap2 = mainMap1 == srcMap ? tempMap1 : srcMap;
		}
		
		this.addChild(new RenderPass(this, [mainMap1, Map0, dirtTex, Map1], mainMap2, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, PostFXShader.post1)));
		this.addChild(new UniformPass(postBlurUniform));
		
		this.addChild(new UniformPass(postBlurUniform));
		postBlurPass = new RenderPass(this, [mainMap2, noiseTex], mainMap1, ShaderBlendMode.NONE, GL.LINEAR, GL.REPEAT, new PrimitiveShader(VertexShader.vert, PostFXShader.postBlur));
		postBlur2Pass = new RenderPass(this, [mainMap1], mainMap2, ShaderBlendMode.NONE, GL.LINEAR, GL.MIRRORED_REPEAT, new PrimitiveShader(VertexShader.vert, PostFXShader.postBlur2));
		this.addChild(postBlurPass);
		this.addChild(postBlur2Pass);
		
		this.addChild(new RenderPass(this, [], Map4A, ShaderBlendMode.NONE, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, PostFXShader.post2)));
		this.addChild(new UniformPass(postFXUniform));
		this.addChild(new RenderPass(this, [mainMap2, Map4A], backBuffer, ShaderBlendMode.ALPHA, GL.LINEAR, GL.CLAMP_TO_EDGE, new PrimitiveShader(VertexShader.vert, PostFXShader.post3)));
	
		this.addChild(overlay);
		//*/
	}
    
    public function fxUniform():Void
    {
        //add fade
        //add displacement
        fxscrollPos.copy(screen.getParallax(NRFDisplay.centerPos, fxDepth));
		var zoom:Float = fxDepth == screen.cameraDepth ? 0 : 1 / (fxDepth - screen.cameraDepth);
        var diff:Vec2D = fxscrollPos.sub(fxscrollPosLF).mulXYSelf(zoom, zoom);
        param0 = [UniformType.FLOAT2, [diff.x, -diff.y]];
        fxscrollPosLF.copy(fxscrollPos);
    }
	
	public function fxClear():Void
    {
        fx.graphics.clear();
    }
	
	public function motionClear():Void
    {
        motion.graphics.clear();
    }
	
	public function godRaysUniform():Void
	{
		param0 = [UniformType.FLOAT2, [godRaysX / NRFDisplay.rawWidth, 1 - godRaysY / NRFDisplay.rawHeight]];
		param1 = [UniformType.FLOAT, [godRaysAmount * NRFDisplay.godRaysIntensity]];
		param2 = [UniformType.FLOAT2, [godRaysRadius1 / NRFDisplay.rawWidth, godRaysRadius2 / NRFDisplay.rawWidth]];
	}
	
	public function postFXUniform():Void
	{
		param0 = [UniformType.FLOAT, [NRFDisplay.chromaticAberrationSize * ((screen.cameraZoom - 1) * NRFDisplay.chromaticAberrationZoomMultiplier + 1)]];
	}
	
	public function postBlurUniform():Void
	{
		if (postBlurRadius > 0){
			param0 = [UniformType.FLOAT, [postBlurRadius]];
			this.postBlurPass.visible = true;
			this.postBlur2Pass.visible = true;
		}
		else {
			this.postBlurPass.visible = false;
			this.postBlur2Pass.visible = false;
		}
	}

	private function initializeFrameBuffer():Void 
	{
		src = new Array<GLTexture>();
		dest = new Array<GLFramebuffer>();
		renderBuffer = new Array<GLRenderbuffer>();
		
		src.push(null);
		dest.push(null);
		renderBuffer.push(null);
		
		for (h in 1...numTexture+1) {
			src.push(GL.createTexture());
			dest.push(GL.createFramebuffer());
			renderBuffer.push(GL.createRenderbuffer());
		}
		
		var _data:UInt8Array = null;
		
		src.push(GL.createTexture());
		var _dirtTex = AssetsManager.decodeBitmapData("engine_textures/LensDirt");
		GL.bindTexture(GL.TEXTURE_2D, src[dirtTex]);
		_data = new UInt8Array(_dirtTex.getPixels(_dirtTex.rect));
		GL.texImage2D(	GL.TEXTURE_2D,
						0,
						GL.RGBA, 
						_dirtTex.width,
						_dirtTex.height, 
						0, 
						GL.RGBA,
						GL.UNSIGNED_BYTE,
						_data);
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_S,
						  GL.CLAMP_TO_EDGE );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_T,
						  GL.CLAMP_TO_EDGE );		
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MIN_FILTER ,
						  GL.LINEAR );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MAG_FILTER,
						  GL.LINEAR );
						  
		src.push(GL.createTexture());
		var _noiseTex = AssetsManager.decodeBitmapData("engine_textures/Noise");
		GL.bindTexture(GL.TEXTURE_2D, src[noiseTex]);
		_data = new UInt8Array(_noiseTex.getPixels(_noiseTex.rect));
		GL.texImage2D(	GL.TEXTURE_2D,
						0,
						GL.RGBA, 
						_noiseTex.width,
						_noiseTex.height, 
						0, 
						GL.RGBA,
						GL.UNSIGNED_BYTE,
						_data);
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_S,
						  GL.REPEAT );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_T,
						  GL.REPEAT );		
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MIN_FILTER ,
						  GL.LINEAR );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MAG_FILTER,
						  GL.LINEAR );
		
		resizeFrameBuffer(null);
	}
	
	private function resizeFrameBuffer(event:Event):Void
	{
		for (h in 1...numTexture+1) {
			GL.bindTexture(GL.TEXTURE_2D, src[h]);
			GL.texImage2D(	GL.TEXTURE_2D,
							0,
							GL.RGBA, 
							Convert.int(Lib.current.stage.stageWidth*texResolution[h]),
							Convert.int(Lib.current.stage.stageHeight*texResolution[h]), 
							0, 
							GL.RGBA,
							GL.UNSIGNED_BYTE,
							null);
			
			
			GL.texParameteri( GL.TEXTURE_2D , 
							  GL.TEXTURE_WRAP_S,
							  GL.CLAMP_TO_EDGE );
			GL.texParameteri( GL.TEXTURE_2D , 
							  GL.TEXTURE_WRAP_T,
							  GL.CLAMP_TO_EDGE );		
			GL.texParameteri( GL.TEXTURE_2D , 
							  GL.TEXTURE_MIN_FILTER ,
							  GL.LINEAR );
			GL.texParameteri( GL.TEXTURE_2D , 
							  GL.TEXTURE_MAG_FILTER,
							  GL.LINEAR );   

			//Bind renderbuffer and create depth buffer. 
			GL.bindRenderbuffer( GL.RENDERBUFFER, renderBuffer[h]);
			GL.renderbufferStorage( GL.RENDERBUFFER,
									GL.DEPTH_COMPONENT16,
									Convert.int(Lib.current.stage.stageWidth*texResolution[h]),
									Convert.int(Lib.current.stage.stageHeight*texResolution[h]));
			
			// bind the framebuffer
			GL.bindFramebuffer(GL.FRAMEBUFFER, dest[h]);

			//specify texture as color attachment
			GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, src[h], 0);


			//Specify depthRenderbuffer as depth attachement.
			GL.framebufferRenderbuffer( GL.FRAMEBUFFER , 
										GL.DEPTH_ATTACHMENT,
										GL.RENDERBUFFER,
										renderBuffer[h]);
										
		}
		
		var status = GL.checkFramebufferStatus( GL.FRAMEBUFFER );
		switch( status ){

			case GL.FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
				trace("FRAMEBUFFER_INCOMPLETE_ATTACHMENT");

			case GL.FRAMEBUFFER_UNSUPPORTED:
				trace("GL_FRAMEBUFFER_UNSUPPORTED");

			case GL.FRAMEBUFFER_COMPLETE:
				trace("GL_FRAMEBUFFER_COMPLETE");

			default:
				trace("Check frame buffer:", status);
		}
		
		GL.bindFramebuffer(GL.FRAMEBUFFER, null);
	}
	
}