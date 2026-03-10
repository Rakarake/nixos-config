
#define PI 3.1415926538

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution;

    vec2 lines_uv = uv;

    // twist?
    // distance from middle
    float distance = distance(uv, vec2(0.5, 0.5));
    float inverse_distance = 1.0 - distance;
    float inverse_distance_magnified = inverse_distance*inverse_distance;
    //lines_uv += (lines_uv - vec2(0.5, 0.5)) * inverse_distance * 3.0;
    float rot = PI * (inverse_distance_magnified);
    mat2x2 rotm = mat2x2(
        cos(rot), -sin(rot),
        sin(rot), cos(rot)
    );
    lines_uv *= rotm;

    // The lines themselves
    float lines_timescale = iTime * 0.3;
    //lines_uv.x += lines_timescale * 0.02;
    lines_uv.y += sin(lines_timescale * 0.2 + lines_uv.x * 5.0) * 0.2;
    lines_uv.x += sin(lines_timescale + lines_uv.y * 30.0) * 0.2;// * sin(lines_timescale);
    float hor_lines = sin(lines_uv.x * 10.0)/2.0 + 0.5;

    float frac = 0.50;
    fragColor = vec4(hor_lines * frac, hor_lines * frac, hor_lines * frac + 0.4, 1.0);
}
