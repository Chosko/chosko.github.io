/* Main function, uniforms & utils */
#ifdef GL_ES
    precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2  EDGE_THICKNESS = vec2(0.01); 
float TILING         = (8.0 * (1.2 - cos(u_time * 0.2)));
float RANDOMIZE      = (0.5 * sin (u_time * 0.3) + 0.5);

vec2 rand(in vec2 v) {
    return fract(sin(vec2(dot(v,vec2(127.1,311.7)),dot(v,vec2(269.5,183.3))))*43758.5453);
}

// screen coords to fract(uv) + floor(uv)
vec4 coords (in vec2 c) {
  vec2 uv = (c.xy - 0.5 * u_resolution.xy) / min(u_resolution.x, u_resolution.y);
  return vec4(fract(uv * TILING), floor(uv * TILING));
}

float voronoi (in vec4 uv, in vec4 mouse) {
    float dist = 1000.0;
    for (int i = -1; i <= 1; i++){
        for (int j = -1; j <= 1; j++) {
            vec2 random = rand(uv.zw + vec2(i,j));
            vec2 point = RANDOMIZE * random + vec2(i,j);
            point += 0.3 * RANDOMIZE * random * vec2(sin(u_time * random.x), cos(u_time * random.y));
            dist = min (dist, distance (point, uv.xy));
        }
    }
    dist = min (dist, distance (mouse.xy + mouse.zw, uv.xy + uv.zw));
    return dist;
}

float voronoiEdges (in vec4 uv, in vec4 mouse) {
    float result = 0.0;
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            result -= voronoi (uv + vec4(EDGE_THICKNESS, 0.0, 0.0) * vec4 (i, j, 0.0, 0.0), mouse);
        }
    }
    result += 9.0 * voronoi(uv, mouse);
    return float(result + 0.0025 < 0.002);
}

void main() {
    vec4 uv = coords (gl_FragCoord.xy);
    vec4 mouse = coords (u_mouse.xy);

    float v = voronoiEdges (uv, mouse);
    
    gl_FragColor = vec4(v, v, v, 1.0);
}