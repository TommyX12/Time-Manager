package engine.shaders;

import engine.display.AdvancedViewport;
import engine.utils.Convert;
import engine.display.Viewport;
import openfl.gl.*;
import openfl.display.OpenGLView;
import flash.geom.*;
import openfl.utils.Float32Array;
import openfl.Lib;

class RenderPass extends OpenGLView {
	private var viewport:AdvancedViewport;
    private var texture0 : GLTexture;
	private var texture1 : GLTexture;
	private var texture2 : GLTexture;
	private var texture3 : GLTexture;
	private var numTexture:Int;
    private var shader: PrimitiveShader;
    private var framebuffer : GLFramebuffer;
	private var blendmode : Int;
	private var texFilter:Int;
	private var texWarp:Int;

    private var buffer:GLBuffer;
    private var texCoordBuffer:GLBuffer;

    private var positionAttribute:Int;
    //private var vertexPosition:Int;
    private var mVertexSlot:Int;

	private var texture0Uniform:Int;
    private var texture1Uniform:Int;
	private var texture2Uniform:Int;
	private var texture3Uniform:Int;
	private var param0Uniform:Int;
    private var param1Uniform:Int;
	private var param2Uniform:Int;
	private var param3Uniform:Int;
	private var timeUniform:Int;
	private var mouseUniform:Int;
	private var resolutionUniform:Int;
    private var texCoordAttribute:Int;
	private var destResolution:Float;

    public function new(viewport:AdvancedViewport, srcTextures:Array<Int>, destFrameBuffer:Int, blendMode:Int, texFilter:Int, texWarp:Int, shader:PrimitiveShader)
    {
        super();
		
		this.viewport = viewport;
        this.framebuffer = viewport.dest[destFrameBuffer];
		numTexture = srcTextures.length;
		if (numTexture >= 1){
			texture0 = viewport.src[srcTextures[0]];
		}
		if (numTexture >= 2){
			texture1 = viewport.src[srcTextures[1]];
		}
		if (numTexture >= 3){
			texture2 = viewport.src[srcTextures[2]];
		}
		if (numTexture >= 4){
			texture3 = viewport.src[srcTextures[3]];
		}
        this.shader = shader;
		this.blendmode = blendMode;
		this.destResolution = viewport.texResolution[destFrameBuffer];
		this.texFilter = texFilter;
		this.texWarp = texWarp;

        mVertexSlot = GL.getAttribLocation (this.shader.program, "aVertex");
        texCoordAttribute = GL.getAttribLocation (this.shader.program, "aTexCoord");
		texture0Uniform = GL.getUniformLocation (this.shader.program, "source0");
        texture1Uniform = GL.getUniformLocation (this.shader.program, "source1");
		texture2Uniform = GL.getUniformLocation (this.shader.program, "source2");
		texture3Uniform = GL.getUniformLocation (this.shader.program, "source3");
		param0Uniform = GL.getUniformLocation (this.shader.program, "param0");
        param1Uniform = GL.getUniformLocation (this.shader.program, "param1");
		param2Uniform = GL.getUniformLocation (this.shader.program, "param2");
		param3Uniform = GL.getUniformLocation (this.shader.program, "param3");
		timeUniform = GL.getUniformLocation (this.shader.program, "time");
		mouseUniform = GL.getUniformLocation (this.shader.program, "mouse");
		resolutionUniform = GL.getUniformLocation( this.shader.program, "resolution");

        createBuffers();
		
		//this.render = _render;
    }

    public function createBuffers():Void 
    {
        var vertices = [
        -1.0, -1.0,
         1.0, -1.0, 
        -1.0, 1.0,
         1.0, -1.0,
         1.0, 1.0, 
        -1.0, 1.0
        ];

        buffer = GL.createBuffer ();
        GL.bindBuffer (GL.ARRAY_BUFFER, buffer);
        GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast vertices), GL.STATIC_DRAW);
        GL.bindBuffer (GL.ARRAY_BUFFER, null);

        var texCoords = [
            
            0, 0, 
            1, 0, 
            0, 1, 
            1, 0,
            1, 1,
            0, 1 
        ];
        
        texCoordBuffer = GL.createBuffer ();
        GL.bindBuffer (GL.ARRAY_BUFFER, texCoordBuffer);
        GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast texCoords), GL.STATIC_DRAW);
        GL.bindBuffer (GL.ARRAY_BUFFER, null);
    }
 
	//public function _render() {
    override public function render(rect : Rectangle) {
        GL.bindFramebuffer(GL.FRAMEBUFFER, this.framebuffer);

        GL.viewport (0, 0, Convert.int(NRFDisplay.currentWidth*destResolution), Convert.int(NRFDisplay.currentHeight*destResolution));
		
		//clear dest texture
        GL.clearColor (0.0, 0.0, 0.0, 0.0);
        //GL.clear (GL.DEPTH_BUFFER_BIT |GL.COLOR_BUFFER_BIT);

        if (shader.program == null) return;
        
        GL.useProgram(this.shader.program);
       
        GL.enableVertexAttribArray (mVertexSlot);
        GL.enableVertexAttribArray (texCoordAttribute);

        GL.activeTexture (GL.TEXTURE0 + 0);
        GL.bindTexture (GL.TEXTURE_2D, this.texture0);	
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MIN_FILTER ,
						  texFilter );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MAG_FILTER,
						  texFilter );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_S,
						  texWarp );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_T,
						  texWarp );	
		GL.activeTexture (GL.TEXTURE0 + 1);
        GL.bindTexture (GL.TEXTURE_2D, this.texture1);	
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MIN_FILTER ,
						  texFilter );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MAG_FILTER,
						  texFilter );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_S,
						  texWarp );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_T,
						  texWarp );	
		GL.activeTexture (GL.TEXTURE0 + 2);
        GL.bindTexture (GL.TEXTURE_2D, this.texture2);	
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MIN_FILTER ,
						  texFilter );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MAG_FILTER,
						  texFilter );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_S,
						  texWarp );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_T,
						  texWarp );	
		GL.activeTexture (GL.TEXTURE0 + 3);
        GL.bindTexture (GL.TEXTURE_2D, this.texture3);	
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MIN_FILTER ,
						  texFilter );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_MAG_FILTER,
						  texFilter );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_S,
						  texWarp );
		GL.texParameteri( GL.TEXTURE_2D , 
						  GL.TEXTURE_WRAP_T,
						  texWarp );	
		
        GL.enable (GL.TEXTURE_2D);

        GL.bindBuffer (GL.ARRAY_BUFFER, buffer); 
        GL.vertexAttribPointer (mVertexSlot, 2, GL.FLOAT, false, 0, 0);

        GL.bindBuffer (GL.ARRAY_BUFFER, texCoordBuffer);
        GL.vertexAttribPointer (texCoordAttribute, 2, GL.FLOAT, false, 0, 0);

        GL.uniform1i (texture0Uniform, 0);
		GL.uniform1i (texture1Uniform, 1);
		GL.uniform1i (texture2Uniform, 2);
		GL.uniform1i (texture3Uniform, 3);
		
		if (viewport.param0[0] == UniformType.FLOAT) GL.uniform1f (param0Uniform, viewport.param0[1][0]);
		else if (viewport.param0[0] == UniformType.FLOAT2) GL.uniform2f (param0Uniform, viewport.param0[1][0], viewport.param0[1][1]);
		else if (viewport.param0[0] == UniformType.FLOAT3) GL.uniform3f (param0Uniform, viewport.param0[1][0], viewport.param0[1][1], viewport.param0[1][2]);
		else if (viewport.param0[0] == UniformType.FLOAT4) GL.uniform4f (param0Uniform, viewport.param0[1][0], viewport.param0[1][1], viewport.param0[1][2], viewport.param0[1][3]);
		if (viewport.param1[0] == UniformType.FLOAT) GL.uniform1f (param1Uniform, viewport.param1[1][0]);
		else if (viewport.param1[0] == UniformType.FLOAT2) GL.uniform2f (param1Uniform, viewport.param1[1][0], viewport.param1[1][1]);
		else if (viewport.param1[0] == UniformType.FLOAT3) GL.uniform3f (param1Uniform, viewport.param1[1][0], viewport.param1[1][1], viewport.param1[1][2]);
		else if (viewport.param1[0] == UniformType.FLOAT4) GL.uniform4f (param1Uniform, viewport.param1[1][0], viewport.param1[1][1], viewport.param1[1][2], viewport.param1[1][3]);
		if (viewport.param2[0] == UniformType.FLOAT) GL.uniform1f (param2Uniform, viewport.param2[1][0]);
		else if (viewport.param2[0] == UniformType.FLOAT2) GL.uniform2f (param2Uniform, viewport.param2[1][0], viewport.param2[1][1]);
		else if (viewport.param2[0] == UniformType.FLOAT3) GL.uniform3f (param2Uniform, viewport.param2[1][0], viewport.param2[1][1], viewport.param2[1][2]);
		else if (viewport.param2[0] == UniformType.FLOAT4) GL.uniform4f (param2Uniform, viewport.param2[1][0], viewport.param2[1][1], viewport.param2[1][2], viewport.param2[1][3]);
		if (viewport.param3[0] == UniformType.FLOAT) GL.uniform1f (param3Uniform, viewport.param3[1][0]);
		else if (viewport.param3[0] == UniformType.FLOAT2) GL.uniform2f (param3Uniform, viewport.param3[1][0], viewport.param3[1][1]);
		else if (viewport.param3[0] == UniformType.FLOAT3) GL.uniform3f (param3Uniform, viewport.param3[1][0], viewport.param3[1][1], viewport.param3[1][2]);
		else if (viewport.param3[0] == UniformType.FLOAT4) GL.uniform4f (param3Uniform, viewport.param3[1][0], viewport.param3[1][1], viewport.param3[1][2], viewport.param3[1][3]);
		
		GL.uniform1f (timeUniform, Convert.second(viewport.time));
		GL.uniform2f (resolutionUniform, NRFDisplay.currentWidth * destResolution, NRFDisplay.currentHeight * destResolution);
		GL.uniform2f (mouseUniform, Lib.current.stage.mouseX / NRFDisplay.currentWidth, 1 - Lib.current.stage.mouseY / NRFDisplay.currentHeight);
		GL.enable(GL.BLEND);
		if (blendmode == ShaderBlendMode.NONE) {
			GL.blendEquation(GL.FUNC_ADD);
			GL.blendFunc(GL.ONE, GL.ZERO);
		}
		else if (blendmode == ShaderBlendMode.ALPHA) {
			GL.blendEquation(GL.FUNC_ADD);
			//GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
			GL.blendFuncSeparate(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA, GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
		}
		else if (blendmode == ShaderBlendMode.ADD) {
			GL.blendEquation(GL.FUNC_ADD);
			GL.blendFunc(GL.SRC_ALPHA, GL.ONE);
		}
		else if (blendmode == ShaderBlendMode.REVERSE_SUBTRACT) {
			GL.blendEquation(GL.FUNC_SUBTRACT);
			GL.blendFunc(GL.SRC_ALPHA, GL.ONE);
		}
		else if (blendmode == ShaderBlendMode.SUBTRACT) {
			GL.blendEquation(GL.FUNC_REVERSE_SUBTRACT);
			GL.blendFunc(GL.SRC_ALPHA, GL.ONE);
		}
		else if (blendmode == ShaderBlendMode.SCREEN) {
			GL.blendEquation(GL.FUNC_ADD);
			GL.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_COLOR);
		}
		else if (blendmode == ShaderBlendMode.MULTIPLY) {
			GL.blendEquation(GL.FUNC_ADD);
			GL.blendFunc(GL.DST_COLOR, GL.ONE_MINUS_SRC_ALPHA);
		}
        GL.drawArrays (GL.TRIANGLES, 0, 6);
        
        GL.bindBuffer (GL.ARRAY_BUFFER, null);
        GL.disable (GL.TEXTURE_2D);
        GL.bindTexture (GL.TEXTURE_2D, null);
        
        GL.disableVertexAttribArray (mVertexSlot);
        GL.disableVertexAttribArray (texCoordAttribute);
        GL.useProgram (null);

        //Check gl error. 
        if( GL.getError() == GL.INVALID_FRAMEBUFFER_OPERATION ){
            trace("INVALID_FRAMEBUFFER_OPERATION!!");
        }
    }
}