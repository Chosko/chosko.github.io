precision highp float;

uniform vec2 u_resolution;
uniform float u_time;

vec2 transformScreenCoords(in vec2 coords){
  vec2 res = coords.xy - 0.5 * u_resolution;
  return 2.0 * res / min(u_resolution.x, u_resolution.y);
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

void main( void )
{
  vec2 uv = 1.768 * transformScreenCoords(gl_FragCoord.xy);
  vec2 d = 1.256 * vec2(sin(u_time), cos(u_time));
  d = normalize(uv - d);
  uv -= d * sin(u_time * 0.1278624);
  uv = abs(fract(uv) * 2.0 - 1.0);
  float pattern = makePattern(uv, 3.0 * (1.33 + sin(4.7 + u_time * 0.5)));
  gl_FragColor = vec4(pattern, pattern, pattern, 1.0);
}
