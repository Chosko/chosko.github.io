precision highp float;

#define BORDER_COLOR vec4(0.86,0.78,0.48,1.000)
#define DISK_COLOR vec4(0.33,0.19,0.55, 1.0)
#define THICKNESS 0.336
#define REPEAT 7.00
#define SIZE 2.336
#define FADESPEED 0.340
#define GRID_SIZE 0.004

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform sampler2D u_buffer0;
uniform float u_delta;

vec2 transformScreenCoords(in vec2 coords){
    vec2 res = coords.xy;
    return GRID_SIZE * res;
}

void main()
{
    #if defined( BUFFER_0 )
    vec2 uv = transformScreenCoords(gl_FragCoord.xy);
    vec2 cell = floor(uv * REPEAT);
    vec2 selectedCell = floor(transformScreenCoords(u_mouse.xy) * REPEAT);
    uv = fract(uv * REPEAT);

    vec2 center = uv - vec2(0.5, 0.5);
    float d = dot(center, center) * 4.0 * SIZE;
    float full = 1.0 - floor(d * (1.0 + THICKNESS));
    float empty = (1.0 - floor(d)) * (floor(d * (1.0 + THICKNESS)));

    float selected = float(cell == selectedCell);

    float bb = texture2D(u_buffer0, gl_FragCoord.xy / u_resolution.xy).r;
    bb = max(bb - FADESPEED * u_delta, 0.0);

    gl_FragColor = vec4(max(full * selected, bb), empty * (1.0 - selected), 0.0, 1.0);

    #else
    vec2 p = texture2D(u_buffer0, gl_FragCoord.xy / u_resolution.xy).rg;
    gl_FragColor = p.r * DISK_COLOR + p.g * BORDER_COLOR;
    #endif
}
