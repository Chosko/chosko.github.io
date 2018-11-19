precision highp float;

#define TILING 4.0

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

vec2 transformScreenCoords(in vec2 coords){
  vec2 res = coords.xy - 0.5 * u_resolution;
  return TILING * res / min(u_resolution.x, u_resolution.y);
}

float makePattern(vec2 uv, float sub){
  uv *= sub;
  vec2 ij = floor(uv);
  sub = 1.0/sub;
  vec2 p = step(fract(uv), sub * ij);
  float pattern = p.x * p.y;
  p = 1.0 - p;
  pattern += p.x * p.y;
  return pattern;
}

void main()
{
  vec2 uv = transformScreenCoords(gl_FragCoord.xy);
  vec2 d = transformScreenCoords(u_mouse);
  d = normalize(uv - d);
  uv -= d * sin(u_time * 0.1278624);
  uv = abs(fract(uv) * 2.0 - 1.0);
  float pattern = makePattern(uv, 3.0 * (1.33 + sin(4.7 + u_time * 0.5)));
  gl_FragColor = vec4(pattern, pattern, pattern, 1.0);
}
