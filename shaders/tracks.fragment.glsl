precision highp float;

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform sampler2D u_buffer0;

vec2 transformScreenCoords(in vec2 coords){
    vec2 res = coords.xy - 0.5 * u_resolution.xy;
    return 2.0 * res / min(u_resolution.x, u_resolution.y);
}

void main( void )
{
    #if defined( BUFFER_0 )
    gl_FragColor = vec4(1.0,0.0,0.0,1.0);
    #else
    vec2 uv = transformScreenCoords(gl_FragCoord.xy);
    vec2 mouse = transformScreenCoords(u_mouse);

    gl_FragColor = texture2D(u_buffer0, gl_FragCoord.xy / u_resolution);
    #endif
}
