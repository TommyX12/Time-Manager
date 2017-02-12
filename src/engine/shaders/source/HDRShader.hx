package engine.shaders.source;
import engine.utils.Convert;

/**
 * ...
 * @author TommyX
 */
class HDRShader
{
	private static var bloom1sample:Int = 11;
	private static var bloom1size:Float = 1.75;//4
	private static var bloom2sample:Int = 7;
	private static var bloom2size:Float = 0.72;//3
	private static var bloom3sample:Int = 11;
	private static var bloom3size:Float = 1.25;//16
	private static var bloom4sample:Int = 11;
	private static var bloom4size:Float = 1.05;//4
	private static var bloom5sample:Int = 13;
	private static var bloom5size:Float = 1.5;//8
	private static var streaksample:Int = 52;//highest 64, lower 32
	private static var streaksize:Float = 4;
	private static var bloomintensity:Float = 1.75;//higher when quality is lower
	private static var streakintensity:Float = 3.8;//2.1;//higher when quality is lower
	private static var flare1pos:Float = -0.35;
	private static var flare1intensity:Float = 0.28;
	private static var flare2pos:Float = -2.2;
	private static var flare2intensity:Float = 0.18;
	private static var flare3posX:Float = -0.75;
	private static var flare3posY:Float = 0.9;
	private static var flare3intensity:Float = 0.065;
	
	public static function bloomprepass():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;
	
	const vec3 sqr = vec3(2.0);

	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = texture2D(source0, position).rgb;
	color.rgb = pow(color.rgb, sqr);
	color.rgb = pow(color.rgb, sqr);
	color.rgb = pow(color.rgb, sqr);
	gl_FragColor = vec4(pow(color.rgb, sqr), 1.0 );
	}
	';
	return string; }
	
	public static function streakprepass():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;
	
	const vec3 sqr = vec3(2.0);
	const vec3 cub = vec3(3.0);
	const vec3 mult = vec3(0.3, 0.5, 1.0);

	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = texture2D(source0, position).rgb;
	color.rgb = pow(color.rgb, sqr);
	color.rgb = pow(color.rgb, sqr);
	color.rgb = pow(color.rgb, sqr);
	color.rgb = pow(color.rgb, cub);
	gl_FragColor = vec4(color * mult, 1.0 );
	}
	';
	return string; }
	
	public static function bloom1x():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resx = 1 / resolution.x;
	';
	
	var h:Float = (1 - bloom1sample) * bloom1size / 2;
	var i:Int = 0;
	while (i < bloom1sample) {
		string += '
			color += texture2D(source0, vec2(position.x + ' + Convert.string(h) + '*resx, position.y)).rgb;
		';
		h += bloom1size;
		i++;
	}
	
	string += '
	gl_FragColor = vec4( color * ' + Convert.string(1/bloom1sample*bloomintensity) + ', 1.0 );
	}
	';
	return string; }
	
	public static function bloom1y():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resy = 1 / resolution.y;
	';
	
	var h:Float = (1 - bloom1sample) * bloom1size / 2;
	var i:Int = 0;
	while (i < bloom1sample) {
		string += '
			color += texture2D(source0, vec2(position.x, position.y + ' + Convert.string(h) + '*resy)).rgb;
		';
		h += bloom1size;
		i++;
	}
	
	string += '
	gl_FragColor = vec4( color * ' + Convert.string(1/bloom1sample*bloomintensity) + ', 1.0 );
	}
	';
	return string; }
	
	public static function bloom2x():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resx = 1 / resolution.x;
	';
	
	var h:Float = (1 - bloom2sample) * bloom2size / 2;
	var i:Int = 0;
	while (i < bloom2sample) {
		string += '
			color += texture2D(source0, vec2(position.x + ' + Convert.string(h) + '*resx, position.y)).rgb;
		';
		h += bloom2size;
		i++;
	}
	
	string += '
	gl_FragColor = vec4( color*' + Convert.string(1/bloom2sample*bloomintensity) + ', 1.0 );
	}
	';
	return string; }
	
	public static function bloom2y():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resy = 1 / resolution.y;
	';
	
	var h:Float = (1 - bloom2sample) * bloom2size / 2;
	var i:Int = 0;
	while (i < bloom2sample) {
		string += '
			color += texture2D(source0, vec2(position.x, position.y + ' + Convert.string(h) + '*resy)).rgb;
		';
		h += bloom2size;
		i++;
	}
	
	string += '
	gl_FragColor = vec4( color*' + Convert.string(1/bloom2sample*bloomintensity) + ', 1.0 );
	}
	';
	return string; }
	
	public static function bloom3x():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resx = 1 / resolution.x;
	';
	
	var h:Float = (1 - bloom3sample) * bloom3size / 2;
	var i:Int = 0;
	while (i < bloom3sample) {
		string += '
			color += texture2D(source0, vec2(position.x + ' + Convert.string(h) + '*resx, position.y)).rgb;
		';
		h += bloom3size;
		i++;
	}
	
	string += '
	color *= ' + Convert.string(1/bloom3sample*bloomintensity) + ';
	color += texture2D(source0, vec2(0.5 + (position.x - 0.5) * ' + Convert.string(1/flare2pos) + ', 0.5 + (position.y - 0.5) * ' + Convert.string(1/flare2pos) + ')).rgb*' + Convert.string(flare2intensity) + ';
		
	gl_FragColor = vec4( color, 1.0 );
	}
	';
	return string; }
	
	public static function bloom3y():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resy = 1 / resolution.y;
	';
	
	var h:Float = (1 - bloom3sample) * bloom3size / 2;
	var i:Int = 0;
	while (i < bloom3sample) {
		string += '
			color += texture2D(source0, vec2(position.x, position.y + ' + Convert.string(h) + '*resy)).rgb;
		';
		h += bloom3size;
		i++;
	}
	
	string += '
	color *= ' + Convert.string(1/bloom3sample*bloomintensity) + ';
	color += texture2D(source0, vec2(0.5 + (position.x - 0.5) * ' + Convert.string(1/flare2pos) + ', 0.5 + (position.y - 0.5) * ' + Convert.string(1/flare2pos) + ')).rgb*' + Convert.string(flare2intensity) + ';
		
	gl_FragColor = vec4( color, 1.0 );
	}
	';
	return string; }
	
	public static function bloom4x():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resx = 1 / resolution.x;
	';
	
	var h:Float = (1 - bloom4sample) * bloom4size / 2;
	var i:Int = 0;
	while (i < bloom4sample) {
		string += '
			color += texture2D(source0, vec2(position.x + ' + Convert.string(h) + '*resx, position.y)).rgb;
		';
		h += bloom4size;
		i++;
	}
	
	string += '
	color *= ' + Convert.string(1/bloom4sample*bloomintensity) + ';
	color += texture2D(source0, vec2(0.5 + (position.x - 0.5) * ' + Convert.string(1/flare3posX) + ', 0.5 + (position.y - 0.5) * ' + Convert.string(1/flare3posY) + ')).rgb * ' + Convert.string(flare3intensity) + ';
		
	gl_FragColor = vec4( color, 1.0 );
	}
	';
	return string; }
	
	public static function bloom4y():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resy = 1 / resolution.y;
	';
	
	var h:Float = (1 - bloom4sample) * bloom4size / 2;
	var i:Int = 0;
	while (i < bloom4sample) {
		string += '
			color += texture2D(source0, vec2(position.x, position.y + ' + Convert.string(h) + '*resy)).rgb;
		';
		h += bloom4size;
		i++;
	}
	
	string += '
	color *= ' + Convert.string(1/bloom4sample*bloomintensity) + ';
	color += texture2D(source0, vec2(0.5 + (position.x - 0.5) * ' + Convert.string(1/flare1pos) + ', 0.5 + (position.y - 0.5) * ' + Convert.string(1/flare1pos) + ')).rgb*' + Convert.string(flare1intensity) + ';
		
	gl_FragColor = vec4( color, 1.0 );
	}
	';
	return string; }
	
	public static function bloom5x():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resx = 1 / resolution.x;
	';
	
	var h:Float = (1 - bloom5sample) * bloom5size / 2;
	var i:Int = 0;
	while (i < bloom5sample) {
		string += '
			color += texture2D(source0, vec2(position.x + ' + Convert.string(h) + '*resx, position.y)).rgb;
		';
		h += bloom5size;
		i++;
	}
	
	string += '
	gl_FragColor = vec4( color*' + Convert.string(1/bloom5sample*bloomintensity) + ', 1.0 );
	}
	';
	return string; }
	
	public static function bloom5y():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resy = 1 / resolution.y;
	';
	
	var h:Float = (1 - bloom5sample) * bloom5size / 2;
	var i:Int = 0;
	while (i < bloom5sample) {
		string += '
			color += texture2D(source0, vec2(position.x, position.y + ' + Convert.string(h) + '*resy)).rgb;
		';
		h += bloom5size;
		i++;
	}
	
	string += '
	gl_FragColor = vec4( color*' + Convert.string(1/bloom5sample*bloomintensity) + ', 1.0 );
	}
	';
	return string; }
	
	public static function streak1():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resx = 1 / resolution.x;
	';
	
	var maxH:Float = (streaksample - 1) * streaksize / 2;
	var h:Float = -maxH;
	var i:Int = 0;
	while (i < streaksample) {
		var lfactor:Float = 1 - (Math.abs(h) / maxH);
		var factor:Float = Math.abs(h);
		if (factor != 0) {
			factor = 1 / factor;
		}
		factor *= lfactor;
		string += 'color += texture2D(source0, vec2(position.x + ' + Convert.string(h) + '*resx, position.y)).rgb * ' + Convert.string(factor) + ';';
		h += streaksize;
		i++;
	}
	
	string += '
	gl_FragColor = vec4( color*' + Convert.string(streakintensity) + ', 1.0 );
	}
	';
	return string; }
	
	public static function streak2():String {
	var string:String = ' //precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;

	void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	float resx = 1 / resolution.x;
	';
	
	var h:Float = (1 - Convert.int(streaksize))/ 2;
	var i:Int = 0;
	while (i < Convert.int(streaksize)) {
		string += '
			color += texture2D(source0, vec2(position.x + ' + Convert.string(h) + '*resx, position.y)).rgb;
		';
		h++;
		i++;
	}
	
	string += '
	gl_FragColor = vec4( color*' + Convert.string(1/Convert.int(streaksize)*streakintensity) + ', 1.0 );
	}
	';
	return string; }
}