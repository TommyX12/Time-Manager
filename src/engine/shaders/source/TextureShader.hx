package engine.shaders.source;

/**
 * ...
 * @author TommyX
 */
class TextureShader
{
	public static function tex():String { return '
	//precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main(void)
	{
		gl_FragColor = texture2D(source0, gl_FragCoord.xy/resolution.xy);
	}
	';}
	
	public static function alphablend():String { return '
	//precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;
	uniform sampler2D source1;

	void main(void)
	{
		vec2 position = gl_FragCoord.xy / resolution.xy;
		vec4 src = texture2D(source0, position);
		vec4 dest = texture2D(source1, position);
		gl_FragColor = vec4(src.rgb * src.a + dest.rgb * (1 - src.a), src.a + dest.a * (1 - src.a));
	}
	';}
}