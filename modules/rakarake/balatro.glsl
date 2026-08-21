// Uhm, stole this stolen balatro shader and changed the colors.
// not mine.

float time;
float vort_speed = 1.;
vec4 colour_1 = vec4(0.8,0.37254901960784315,0.6,1.);
vec4 colour_2 = vec4(0.8,0.615686274509804,0.8,1.);
float mid_flash = 0.;
float vort_offset = 0.;

#define PIXEL_SIZE_FAC 700.
#define BLACK 0.6*vec4(79./255.,99./255., 103./255., 1./0.6)

vec4 easing(vec4 t, float power)
{
    return vec4(pow(t.x, power),
    pow(t.y, power),
    pow(t.z, power),
    pow(t.w, power)
    );
}

vec4 effect( vec3 screen_coords, float scale )
{
    //Convert to UV coords (0-1) and floor for pixel effect
    vec2 uv = screen_coords.xy;
    uv = floor(uv * (PIXEL_SIZE_FAC / 2.)) / (PIXEL_SIZE_FAC / 2.);
    uv /= scale;
    float uv_len = length(uv);

    //Adding in a center swirl, changes with time
    float speed = time*vort_speed;
    float new_pixel_angle = atan(uv.y, uv.x) + (2.2 + 0.4*min(6.,speed))*uv_len - 1. -  speed*0.05 - min(6.,speed)*speed*0.02 + vort_offset;
    vec2 mid = (iResolution.xy/length(iResolution.xy))/2.;
    vec2 sv = vec2((uv_len * cos(new_pixel_angle) + mid.x), (uv_len * sin(new_pixel_angle) + mid.y)) - mid;

	//Now add the smoke effect to the swirled UV

    sv *= 30.;
    speed = time*(6.)*vort_speed + vort_offset + 5.;
	vec2 uv2 = vec2(sv.x+sv.y);

    for(int i=0; i < 5; i++) {
		uv2 += sin(max(sv.x, sv.y)) + sv;
		sv  += 0.5*vec2(cos(5.1123314 + 0.353*uv2.y + speed*0.131121),sin(uv2.x - 0.113*speed));
		sv  -= 1.0*cos(sv.x + sv.y) - 1.0*sin(sv.x*0.711 - sv.y);
	}

    //Make the smoke amount range from 0 - 2
	float smoke_res =min(2., max(-2., 1.5 + length(sv)*0.12 - 0.17*(min(10.,time*1.2 - 0.))));
    if (smoke_res < 0.2) {
        smoke_res = (smoke_res - 0.2)*0.6 + 0.2;
    }
    
    float c1p = max(0.,1. - 2.*abs(1.-smoke_res));
    float c2p = max(0.,1. - 2.*(smoke_res));
    float cb = 1. - min(1., c1p + c2p);

    vec4 ret_col = colour_1*c1p + colour_2*c2p + vec4(cb*BLACK.rgb, cb*colour_1.a);
    float mod_flash = max(mid_flash*0.8, max(c1p, c2p)*5. - 4.4) + mid_flash*max(c1p, c2p);
    
    return easing(ret_col*(1. - mod_flash) + mod_flash*vec4(1., 1., 1., 1.), 1.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec3 uv = vec3(fragCoord.xy/iResolution.xy, 0.);
    uv -= .5;
    uv.x *= iResolution.x / iResolution.y;

    // Time varying pixel color
    vec4 col = vec4(1.,0.,0.,1.);
    time = iTime + 10.;
    // Output to screen
    fragColor = effect(uv * vec3(1.,1.,0.), 2.);
}
