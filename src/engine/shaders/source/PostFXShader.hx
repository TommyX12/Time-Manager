package engine.shaders.source;
import engine.utils.Convert;

/**
 * ...
 * @author TommyX
 */
class PostFXShader
{
	
	public static function post1():String { //combine with hdr, lens dirt, lighten, fxaa
	var string:String = '
	//precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;
	uniform sampler2D source1;
	uniform sampler2D source2; 
	uniform sampler2D source3; ';
	
	if (NRFDisplay.fxaa){string += '

	float width = resolution.x;
	float height = resolution.y;

	float FXAA_SUBPIX_SHIFT = 1.0/4.0;
	vec2 rcpFrame = vec2(1.0/width, 1.0/height);

	vec3 FxaaPixelShader(
	  vec4 posPos, 
	  sampler2D tex, 
	  vec2 rcpFrame) 
	{
	/*---------------------------------------------------------*/
		#define FXAA_REDUCE_MIN   (1.0/128.0)
		#define FXAA_REDUCE_MUL   (1.0/8.0)
		#define FXAA_SPAN_MAX     8.0
	/*---------------------------------------------------------*/
		vec3 rgbNW = texture2D(tex, posPos.zw, 0.0).xyz;
		vec3 rgbNE = texture2D(tex, posPos.zw + vec2(1.0,0.0)*rcpFrame.xy, 0.0).xyz;
		vec3 rgbSW = texture2D(tex, posPos.zw + vec2(0.0,1.0)*rcpFrame.xy, 0.0).xyz;
		vec3 rgbSE = texture2D(tex, posPos.zw + vec2(1.0,1.0)*rcpFrame.xy, 0.0).xyz;
		vec3 rgbM  = texture2D(tex, posPos.xy,0.0).xyz;
	/*---------------------------------------------------------*/
		vec3 luma = vec3(0.299, 0.587, 0.114);
		float lumaNW = dot(rgbNW, luma);
		float lumaNE = dot(rgbNE, luma);
		float lumaSW = dot(rgbSW, luma);
		float lumaSE = dot(rgbSE, luma);
		float lumaM  = dot(rgbM,  luma);
	/*---------------------------------------------------------*/
		float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
		float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
	/*---------------------------------------------------------*/
		vec2 dir;
		dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
		dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
	/*---------------------------------------------------------*/
		float dirReduce = max(
			(lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
			FXAA_REDUCE_MIN);
		float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
		dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),
			  max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
			  dir * rcpDirMin)) * rcpFrame.xy;
	/*--------------------------------------------------------*/
		vec3 rgbA = (1.0/2.0) * (
			texture2D(tex, posPos.xy + dir * (1.0/3.0 - 0.5),0.0).xyz +
			texture2D(tex, posPos.xy + dir * (2.0/3.0 - 0.5),0.0).xyz);
		vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
			texture2D(tex, posPos.xy + dir * (0.0/3.0 - 0.5),0.0).xyz +
			texture2D(tex, posPos.xy + dir * (3.0/3.0 - 0.5),0.0).xyz);
		float lumaB = dot(rgbB, luma);
		if((lumaB < lumaMin) || (lumaB > lumaMax)) return rgbA;
		return rgbB; 
	}';}
	
	string += '
	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy ); ';
	
	if (NRFDisplay.fxaa){string += '
	vec4 posPos = vec4(position.xy,position.xy -(rcpFrame * (0.5 + FXAA_SUBPIX_SHIFT)));
	vec3 color = FxaaPixelShader(posPos, source0, rcpFrame).rgb'; if (!NRFDisplay.motionBlur) string +=' * 1.25'; string += ';';
	}
	else {
		string += '
		vec3 color = texture2D(source0, position.xy).rgb'; if (!NRFDisplay.motionBlur) string +=' * 1.25'; string += ';';
	}
	
	string += '
	vec3 hdr = texture2D(source3, position.xy).rgb;
	color = color * (1 - hdr) + hdr;
	hdr = texture2D(source1, position.xy).rgb;
	color = color * (1 - hdr) + hdr;
	color.rgb = hdr.rgb * texture2D(source2, position.xy).gba + color.rgb;     
	gl_FragColor = vec4(color, 1.0 );
	}
	';
	return string; }
	
	public static function post2():String { //vignette, noise generation
	var string:String = '
	//precision highp float;
	uniform vec2 resolution;
	uniform float time;
	
	float rand(vec2 co) {
		return fract(sin(dot(co.xy,vec2(12.9898 + time,78.233))) * 43758.5453);
	}

	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	float n = rand(position) * '+ Convert.string(NRFDisplay.noiseIntensity) +';
	n += mod(gl_FragCoord.y, 2)* '+ Convert.string(NRFDisplay.scanlineIntensity) +';
	float v = smoothstep('+ Convert.string(NRFDisplay.vignetteRadius / 1280 + NRFDisplay.vignetteFade / 1280) +', '+ Convert.string(NRFDisplay.vignetteRadius / 1280) +', length(0.5 - position));
	gl_FragColor = vec4(n, v, 1.0, 1.0);
	}
	';
	return string; }
	
	public static function post3():String { //chromatic aberration, vignette, noise
	var string:String = '
	//precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;
	uniform sampler2D source1;
	
	uniform float param0;

	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	color.r = texture2D(source0, position.xy - param0 * (position.xy - 0.5)).r;
    color.g = texture2D(source0, position.xy).g;
	color.b = texture2D(source0, position.xy + param0 * (position.xy - 0.5)).b;
    color = mix(texture2D(source0, position.xy).rgb, color, '+ Convert.string(NRFDisplay.chromaticAberrationIntensity) +');
	vec2 mask = texture2D(source1, position.xy).rg;
	gl_FragColor = vec4(color * mask.y - mask.x, 1.0 );
	}
	';
	return string; }
	
	public static function postBlur():String {
	var string:String = '
	//precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;
	uniform sampler2D source1;
	uniform float param0;

	vec2 rcpFrame = vec2(1.0 / resolution.x, 1.0 / resolution.y);
	
	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec2 noisePos = gl_FragCoord.xy / 1024.0;
	vec3 color = vec3(0.0);
	float radius;
    float angle;
    vec2 texpos;
	vec3 rand;
	
	rand = texture2D(source1, noisePos).gba;
	radius = param0 * rand.r;
    angle = rand.g*6.283185307178;
    texpos = vec2(position.x + radius*rcpFrame.x*cos(angle), position.y + radius*rcpFrame.y*sin(angle));
	color += texture2D(source0, texpos).rgb;
	
	rand = texture2D(source1, noisePos).gba;
	radius = param0 * rand.r;
    angle = rand.b*6.283185307178;
    texpos = vec2(position.x + radius*rcpFrame.x*cos(angle), position.y + radius*rcpFrame.y*sin(angle));
	color += texture2D(source0, texpos).rgb;
	
	rand = texture2D(source1, noisePos).gba;
	radius = param0 * rand.g;
    angle = rand.r*6.283185307178;
    texpos = vec2(position.x + radius*rcpFrame.x*cos(angle), position.y + radius*rcpFrame.y*sin(angle));
	color += texture2D(source0, texpos).rgb;
	
	rand = texture2D(source1, noisePos).gba;
	radius = param0 * rand.b;
    angle = rand.r*6.283185307178;
    texpos = vec2(position.x + radius*rcpFrame.x*cos(angle), position.y + radius*rcpFrame.y*sin(angle));
	color += texture2D(source0, texpos).rgb;

	gl_FragColor = vec4(color*0.25, 1.0 );
	}
	';
	return string; }
	
	public static function postBlur2():String {
	var string:String = '
	//precision highp float;
	uniform vec2 resolution;
	uniform sampler2D source0;
	
	const float radius = 0.5;

	vec2 rcpFrame = vec2(1.0 / resolution.x, 1.0 / resolution.y);
	
	void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec3 color = vec3(0.0);
	color += texture2D(source0, position).rgb;
	color += texture2D(source0, position + vec2(-radius * rcpFrame.x, 0.0)).rgb;
	color += texture2D(source0, position + vec2(radius * rcpFrame.x, 0.0)).rgb;
	color += texture2D(source0, position + vec2(0.0, radius * rcpFrame.y)).rgb;
	color += texture2D(source0, position + vec2(0.0, -radius * rcpFrame.y)).rgb;
	gl_FragColor = vec4(color*0.2, 1.0 );
	}
	';
	return string;}
	
}