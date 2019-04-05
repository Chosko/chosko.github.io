precision highp float;

#define TILING 2.0
#define ITERATIONS 255

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

vec3 color1 = vec3(0.940,0.636,0.285);
vec3 color2 = vec3(0.056,1.000,0.367);

vec2 transformScreenCoords(in vec2 coords){
  vec2 res = coords.xy - 0.5 * u_resolution;
  return TILING * res / min(u_resolution.x, u_resolution.y);
}

vec2 cp (in vec2 a, in vec2 b)
{
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + b.x * a.y);
}

vec2 fractal (in vec2 z, in vec2 c, float extents)
{
  int maxIterations = 0;
  for (int i = 0; i < ITERATIONS; i++)
  {
    maxIterations++;
    z = cp(z, z) + c;
    if (i >= ITERATIONS || length(z) >= extents)
      break;
  }

  if (maxIterations < ITERATIONS)
    return vec2(float(maxIterations) / float(ITERATIONS), 0);
  else
    return vec2(0.0, abs(floor(z * float(ITERATIONS)) / float(ITERATIONS)));
}

void main()
{
  vec2 mouse = transformScreenCoords(u_mouse.xy);
  vec2 coord = transformScreenCoords(gl_FragCoord.xy);
  coord += vec2(0.01,-0.01) * (mouse - 0.5);

  float t = u_time + 20.0;
  vec2 params =
    0.005 * vec2(sin(t * 2.0),cos(t * 2.0)) +
    vec2(-0.20, 0.70) +
    vec2(sin(t * 0.26), cos(t * 0.2)) * vec2(0.02,-0.1) +
    mouse * 0.1;
  vec2 julia = fractal(coord, params, 5.0);
  vec3 color = smoothstep(vec3(0.0), color1, pow(vec3(julia.x), vec3(0.5)));

  gl_FragColor = vec4(color, 1.0);
}
