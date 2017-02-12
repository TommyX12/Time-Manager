package engine.shaders.source;
import engine.utils.Convert;

/**
 * ...
 * @author TommyX
 */
class GodRaysShader
{
	private static var godrayssample:Int = 16;
	private static var godrayssize:Float = 0.035;
	private static var godraysintensity:Float = 1;
	private static var godraysrfade:Float = 400 / 1280;
	
	public static function godraysprepass():String {
	var string:String = '
	//precision highp float;
	uniform vec2 resolution;
	uniform vec2 param0; // x, y, 
	uniform vec2 param2; // radius
	uniform sampler2D source0;
	uniform sampler2D source1;

	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = texture2D(source0, position).rgb;
	float mask = 1-texture2D(source1, position).a;
	gl_FragColor = vec4(color * smoothstep(param2.y, param2.x, length(vec2((param0.x - position.x)*resolution.x/resolution.y, param0.y - position.y))) * mask, 1.0 );
	}
	';
	return string; }
	
	public static function godrays():String {
	var string:String = '
	//precision highp float;
	uniform vec2 resolution;
	uniform vec2 param0; // x, y, 
	uniform float param1; // amount, 
	uniform sampler2D source0;
	
	vec2 rcpFrame = vec2('+ Convert.string(1.0/1280.0) +', '+ Convert.string(1.0/1280.0) +'*resolution.x/resolution.y);

	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec2 center = param0.xy;
	vec3 color = vec3(0.0);
	';
	
	for (i in 0...godrayssample) {
		string += '
			color += texture2D(source0, (position - center) * ' + Convert.string(1-(i*godrayssize)) + ' + center).rgb;
		';
	}
	
	string += '
	gl_FragColor = vec4(color * ' + Convert.string(godraysintensity/godrayssample) + '*param1, 1.0 );
	}
	';
	return string; }
}