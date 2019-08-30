/* Main function, uniforms & utils */
#ifdef GL_ES
    precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float TILING         = (8.0 * (1.2 - cos(u_time * 0.2)));
float RANDOMIZE      = (0.5 * sin (u_time * 0.3) + 0.5);

vec2 rand(in vec2 v) {
    v += vec2(123456);
    return fract(sin(vec2(dot(v,vec2(127.1,311.7)),dot(v,vec2(269.5,183.3))))*43758.5453);
}

// screen coords to fract(uv) + floor(uv)
vec4 coords (in vec2 c) {
  vec2 uv = (c.xy - 0.5 * u_resolution.xy) / min(u_resolution.x, u_resolution.y);
  return vec4(fract(uv * TILING), floor(uv * TILING));
}

vec4 voronoiColored (in vec4 uv, in vec4 mouse) {
    float dist = distance (mouse.xy + mouse.zw, uv.xy + uv.zw);
    vec3 color = vec3(0.7255, 0.2314, 0.0314);
    vec4 result = vec4(color, dist);
    float isMin = 0.0;
    for (int i = -1; i <= 1; i++){
        for (int j = -1; j <= 1; j++) {
            vec2 random = rand(uv.zw + vec2(i,j));
            vec2 point = RANDOMIZE * random + vec2(i,j);
            point += 0.3 * RANDOMIZE * random * vec2(sin(u_time * random.x), cos(u_time * random.y));
            dist = distance (point, uv.xy);
            color = vec3(random.xy, random.x + random.y);

            isMin = float(dist < result.w);
            result = isMin * vec4(color, dist) + (1.0 - isMin) * result; 
            
            dist = min (dist, distance (point, uv.xy));
        }
    }
    return result;
}

void main() {
    vec4 uv = coords (gl_FragCoord.xy);
    vec4 mouse = coords (u_mouse.xy);

    vec4 v = voronoiColored (uv, mouse);
    v.xyz = mix(v.xyz, vec3(0.0,0.0,0.0), pow(v.w, 2.0));
    
    gl_FragColor = vec4(v.xyz, 1.0);
}