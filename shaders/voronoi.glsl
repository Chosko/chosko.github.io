/* Main function, uniforms & utils */
#ifdef GL_ES
    precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define POINTS          5

// screen coords to uv
vec2 coords (in vec2 c) {
  return 2.0 * (c.xy - 0.5 * u_resolution.xy) / min(u_resolution.x, u_resolution.y);
}

// voronoi
float voronoi (in vec2[POINTS] points, in vec2 uv)
{
    float df = 1000.0;
    for (int i = 0; i < POINTS; i++) {
        df = min (df, distance(points[i], uv));
    }
    return df;
}

// main
void main() {
    vec2 uv = coords (gl_FragCoord.xy);
    vec2 mouse = coords (u_mouse.xy);

    vec2 rotation = vec2 (sin(u_time), cos(u_time));
    vec2 points [POINTS];

    points[0] = vec2( 0.0, 0.0) + rotation * vec2(0.2, 0.2);
    points[1] = vec2( 0.5, 0.0) + rotation * vec2(-0.3, 0.1);
    points[2] = vec2(-0.5, 0.0) + rotation * vec2(-0.1, 0.4);
    points[3] = vec2( 0.0, 0.5) + rotation * vec2(0.3, -0.15);
    points[4] = mouse;
    
    float df = voronoi (points, uv);

    vec3 color = vec3(df);
    gl_FragColor = vec4(color, 1.0);
}