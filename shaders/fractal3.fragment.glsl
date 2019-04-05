#define ITERATIONS 20
#define POWER 2

precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec3 color1 = vec3(0.940,0.636,0.285);
vec3 color2 = vec3(0.056,1.000,0.367);

vec3 _pseudo_step ( vec4 a, vec4 b, float t)
{
  vec3 color = vec3(0.0,0.0,0.0);
  if(t >= a.a && t < b.a)
  {
    float s = step(0.5,(t - a.a) / (b.a - a.a));
    color = s * a.rgb + (1.0 - s) * b.rgb;
  }
  return color;
}

// =============================================
vec3 pseudo ( float intensity, float min, float max )
{
  vec3 color = vec3(0.0,0.0,0.0);
  vec4 c0 = vec4(0.86, 0.15, 0.11, 0.0);
  vec4 c1 = vec4(0.88, 0.36, 0.14, 0.2);
  vec4 c2 = vec4(0.94, 0.73, 0.19, 0.4);
  vec4 c3 = vec4(0.11, 0.69, 0.56, 0.6);
  vec4 c4 = vec4(0.07, 0.25, 0.36, 0.8);
  vec4 c5 = vec4(0.07, 0.07, 0.07, 1.0);

  if(intensity < min){
    return c0.rgb;
  }
  if(intensity >= max){
    return c5.rgb;
  }

  float i = clamp((intensity - min) / (max - min), 0.0, 1.0);
  color = color + _pseudo_step(c0,c1,i);
  color = color + _pseudo_step(c1,c2,i);
  color = color + _pseudo_step(c2,c3,i);
  color = color + _pseudo_step(c3,c4,i);
  color = color + _pseudo_step(c4,c5,i);
  return color;
}

vec2 normalizeScreenCoords(in vec2 coords){
  vec2 res = coords.xy - 0.5 * u_resolution.xy;
  return 2.0 * res / min(u_resolution.x, u_resolution.y);
}

vec2 cp (in vec2 a, in vec2 b)
{
  return vec2(a.x * b.x - a.y * b.y, a.x * b.y + b.x * a.y);
}

vec2 fractal (in vec2 z, in vec2 c, float extents)
{
  float maxIteration = 0.0;
  for (int i = 0; i < ITERATIONS; i++)
  {
    maxIteration += 1.0;
    z = cp(z, z) + c;
    if (i >= ITERATIONS || length(z) >= extents)
      break;
  }

  if (maxIteration < float(ITERATIONS))
    return vec2(maxIteration / float(ITERATIONS), 1.0);
  else
    return vec2(0.0, abs(floor(z * float(ITERATIONS)) / float(ITERATIONS)));
}

void main()
{
  vec2 mouse = normalizeScreenCoords(u_mouse.xy);
  vec2 coord = normalizeScreenCoords(gl_FragCoord.xy);
  coord += vec2(0.01,-0.01) * (mouse - 0.5);

  float t = u_time + 20.0;
  vec2 params =
    0.1 * vec2(sin(t * 2.0),cos(t * 2.0)) +
    vec2(sin(t * 0.26), cos(t * 0.2)) * vec2(0.500,-0.370) +
    mouse * 0.5;
  vec2 julia = fractal(params, coord, 2.0);

  vec3 color = smoothstep(vec3(0.0), color1, pow(vec3(julia.x), vec3(1.0)));
	color += pseudo(julia.y, 0.0, 1.0);

  gl_FragColor = vec4(color, 1.0);
}
