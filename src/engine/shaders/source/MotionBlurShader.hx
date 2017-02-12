package engine.shaders.source;
import engine.utils.Convert;

/**
 * ...
 * @author TommyX
 */
class MotionBlurShader
{
	private static var motionblursample:Int = 12;
	private static var motionblursize:Float = 2.666;
	
	private static var extension1 = 4.0;
	private static var extension2 = 8.0;
	
	public static function motionblurprepass():String {
	var string:String = '
	//precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;
	
	const vec3 extension1 = vec3(' + Convert.string(extension1) + ', -' + Convert.string(extension1) + ', 0.0);
	const vec3 extension2 = vec3(' + Convert.string(extension2) + ', -' + Convert.string(extension2) + ', 0.0);
	const vec2 one = vec2(1.0);

	vec2 rcpFrame = vec2(1.0/1280.0, 1.0/1280.0*resolution.x/resolution.y);

	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float compair = 0.0;
	color.rgb = texture2D(source0, position.xy).rgb;
	vec3 near = texture2D(source0, rcpFrame.xy * extension1.yy + position.xy).rgb;
	compair = step(dot(color.rg, one), dot(near.rg, one));
	color.rg = max(near.rg, color.rg);
	color.b = mix(color.b, near.b, compair);
	near = texture2D(source0, rcpFrame.xy * extension2.yz + position.xy).rgb;
	compair = step(dot(color.rg, one), dot(near.rg, one));
	color.rg = max(near.rg, color.rg);
	color.b = mix(color.b, near.b, compair);
	near = texture2D(source0, rcpFrame.xy * extension1.yx + position.xy).rgb;
	compair = step(dot(color.rg, one), dot(near.rg, one));
	color.rg = max(near.rg, color.rg);
	color.b = mix(color.b, near.b, compair);
	near = texture2D(source0, rcpFrame.xy * extension2.zy + position.xy).rgb;
	compair = step(dot(color.rg, one), dot(near.rg, one));
	color.rg = max(near.rg, color.rg);
	color.b = mix(color.b, near.b, compair);
	near = texture2D(source0, rcpFrame.xy * extension2.zx + position.xy).rgb;
	compair = step(dot(color.rg, one), dot(near.rg, one));
	color.rg = max(near.rg, color.rg);
	color.b = mix(color.b, near.b, compair);
	near = texture2D(source0, rcpFrame.xy * extension1.xy + position.xy).rgb;
	compair = step(dot(color.rg, one), dot(near.rg, one));
	color.rg = max(near.rg, color.rg);
	color.b = mix(color.b, near.b, compair);
	near = texture2D(source0, rcpFrame.xy * extension2.xz + position.xy).rgb;
	compair = step(dot(color.rg, one), dot(near.rg, one));
	color.rg = max(near.rg, color.rg);
	color.b = mix(color.b, near.b, compair);
	near = texture2D(source0, rcpFrame.xy * extension1.xx + position.xy).rgb;
	compair = step(dot(color.rg, one), dot(near.rg, one));
	color.rg = max(near.rg, color.rg);
	color.b = mix(color.b, near.b, compair);
	gl_FragColor = vec4(color, 1.0 );
	}
	';
	return string; }
	
	public static function motionblur():String {
	var string:String = '
	//precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;
	uniform sampler2D source1;
	
	vec2 rcpFrame = vec2(1.0/1280.0, 1.0/1280.0*resolution.x/resolution.y);

	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	vec3 motion = texture2D(source1, position).rgb;
	motion.g *= sign(motion.b) * 2.0 - 1.0;
	';
	
	for (i in 0...motionblursample) {
		string += '
			color += texture2D(source0, position.xy + (motion.rg * ' + Convert.string(Convert.float(i - Convert.int(motionblursample/2))*motionblursize) + ' * rcpFrame.xy)).rgb;
		';
	}
	
	string += '
	gl_FragColor = vec4(color*' + Convert.string(1.25/motionblursample) + ', 1.0 );
	}
	';
	return string; }
}