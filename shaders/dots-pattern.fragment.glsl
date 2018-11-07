precision highp float;

#define THICKNESS 0.2
#define REPEAT 7.00
#define SIZE 2.2
#define COLOR vec3(0.213,0.007,0.335)
#define FADESPEED 0.003
#iChannel0 buf://self

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

vec2 transformScreenCoords(in vec2 coords){
    vec2 res = coords.xy - 0.5 * iResolution.xy;
    return 2.0 * res / min(iResolution.x, iResolution.y);
}

void main( void )
{
    vec2 uv = transformScreenCoords(gl_FragCoord.xy);
    vec2 cell = floor(uv * REPEAT);
    vec2 selectedCell = floor(transformScreenCoords(iMouse.xy) * REPEAT);
    uv = fract(uv * REPEAT);

    vec2 center = uv - vec2(0.5, 0.5);
    float d = dot(center, center) * 4.0 * SIZE;
    float full = 1.0 - floor(d);
    float empty = full * (floor(d * (1.0 + THICKNESS)));

    float selected = float(cell == selectedCell);
    float pattern = full * selected + empty * (1.0 - selected);

    vec3 bb = texture2D(iChannel0, gl_FragCoord.xy / iResolution.xy).rgb;
    bb = max(bb - FADESPEED, vec3(0.0));

    gl_FragColor = vec4(max(pattern * COLOR, bb), 1.0);
}
