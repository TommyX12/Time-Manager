package engine.shaders.source;

import engine.utils.Convert;

/**
 * ...
 * @author TommyX
 */
class FXShader
{
    public static var fxblursize:Float = 1;
	public static var fxblurcolormul:Float = 0.99;
    public static var fxblurcoloradd:Float = 0.005;
	public static var fxbluralphamul:Float = 1.0;
	public static var fxbluralphaadd:Float = -0.005;

	public static function fx():String { return '
	//precision highp float;
	uniform float time;
	uniform vec2 resolution;
	uniform sampler2D source0;

	vec2 scroll = vec2(2.0,0.0);
	float blurSize = 2.0/resolution.x;

	// Default noise
	float rand(vec2 co) {
		return (fract(sin(dot(co.xy + time*0.5,vec2(12.9898,78.233))) * 43758.5453)*2.0-1.0);
	}

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	
	float a = rand(position);
	float b = rand(position + 0.2);
	
	vec4 color = texture2D(source0, vec2(position.x+scroll.x/resolution.x+a*blurSize, position.y+scroll.y/resolution.y+b*blurSize));
	
	color -= 0.01;
		
	gl_FragColor = color;
	}
	';}
    
    public static function fxblurx():String { return '
	//precision highp float;
    uniform float time;
	uniform vec2 resolution;
	uniform sampler2D source0;

    vec2 rcpFrame = vec2('+ Convert.string(1.0/1280.0) +', '+ Convert.string(1.0/1280.0) +'*resolution.x/resolution.y);

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	
	vec4 color = vec4(0.0);
    
    color += texture2D(source0, position+vec2(-'+ Convert.string(fxblursize) +'*rcpFrame.x, 0.0));
    color += texture2D(source0, position+vec2('+ Convert.string(fxblursize) +'*rcpFrame.x, 0.0));
	
	gl_FragColor = color * 0.5;
	}
    ';}
    
    public static function fxblury():String { return '
	//precision highp float;
    uniform float time;
	uniform vec2 resolution;
	uniform sampler2D source0;
    uniform vec2 param0; //scroll x y

    vec2 rcpFrame = vec2('+ Convert.string(1.0/1280.0) +', '+ Convert.string(1.0/1280.0) +'*resolution.x/resolution.y);
    
	vec2 scroll = param0 * rcpFrame;
	
	const vec4 colorMod = vec4('+ Convert.string(fxblurcolormul * 0.5) +', '+ Convert.string(fxblurcoloradd) +', '+ Convert.string(fxbluralphamul * 0.5) +', '+ Convert.string(fxbluralphaadd) +');

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	
	vec4 color = vec4(0.0);
    
    color += texture2D(source0, position+scroll+vec2(0.0, -'+ Convert.string(fxblursize) +'*rcpFrame.y));
    color += texture2D(source0, position+scroll+vec2(0.0, '+ Convert.string(fxblursize) +'*rcpFrame.y));
	
	gl_FragColor = color.rgba * colorMod.xxxz + colorMod.yyyw;
	}
    ';}

}