precision highp float;

#define TILING 10.0
#define THRESHOLD 0.9
#define LEVELS 5.0

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2 transformScreenCoords(in vec2 uv){
  uv = uv - 0.5 * u_resolution;
  return TILING * uv / min(u_resolution.x, u_resolution.y);
}

float fn(in vec2 uv, in vec2 p) {
  uv = abs(uv - p);
  return 1.0 / dot(uv, uv);
}

void main(void) {
  float meta = 0.0;

  vec2 uv = transformScreenCoords(gl_FragCoord.xy);
  meta += fn(uv, 4.0 * vec2(sin(u_time), cos(u_time)));
  meta += fn(uv, 2.0 * vec2(cos(u_time), sin(u_time)));
  meta += fn(uv, transformScreenCoords(u_mouse));

  meta = floor((meta + THRESHOLD - 1.0) * LEVELS) / LEVELS;

  gl_FragColor = vec4(vec3(meta), 1.0);
}
