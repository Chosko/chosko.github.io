precision highp float;

#define F 1.0
#define ADD 4.0
#define MIN_FLOW 0.3

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform sampler2D u_buffer0;
uniform float u_delta;

vec2 transformScreenCoords(in vec2 coords){
    vec2 res = coords.xy - 0.5 * u_resolution.xy;
    return 2.0 * res / min(u_resolution.x, u_resolution.y);
}

vec4 texOffset (in sampler2D s, in vec2 uv, in ivec2 offset)
{
    return texture2D(s, uv + vec2(offset) / u_resolution);
}

float fetch (in ivec2 offset) {
    return texOffset(u_buffer0, gl_FragCoord.xy / u_resolution, offset).r;
}

vec3 encodeRGB (in float v) {
    return clamp(
        v * 3.0 - vec3(0.0, 1.0, 2.0),
        0.0,
        1.0
    );
}

void main()
{
    // BUFFER 0
    #if defined( BUFFER_0 )
    vec2 uv = transformScreenCoords(gl_FragCoord.xy);
    float c = fetch(ivec2(0,0));
    float factor = u_delta * F *
        (
            0.25 *
            (
                fetch(ivec2( 0, 1)) +
                fetch(ivec2( 1, 0)) +
                fetch(ivec2( 0,-1)) +
                fetch(ivec2(-1, 0))
            ) - c
        );

    if(factor < 0.0 && factor > -MIN_FLOW * u_delta)
        factor = -MIN_FLOW * u_delta;

    c += factor;

    vec2 dst;

    dst= transformScreenCoords(u_mouse) - uv;
    c += ADD * u_delta * max(1.0 - 64.0 * dot(dst, dst), 0.0);
    c = clamp(c, 0.0, 1.0);

    gl_FragColor = vec4(c,0.0,0.0,0.0);

    // MAIN
    #else
    gl_FragColor = vec4(encodeRGB(fetch(ivec2(0,0))),1.0);
    #endif
}
