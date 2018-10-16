#define iterations 30
#define power 2

precision highp float;

uniform vec2 u_resolution;
uniform vec4 u_mouse;
uniform float u_time;

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

// complex product
vec2 cp(in vec2 a, in vec2 b){
  return vec2(
    a.x * b.x - a.y * b.y,
    a.x * b.y + a.y * b.x
  );
}

vec2 normalizeScreenCoords(in vec2 coords){
  vec2 res = coords.xy - 0.5 * u_resolution.xy;
  return 2.0 * res / min(u_resolution.x, u_resolution.y);
}

vec2 fractal(in vec2 z0, in vec2 c){
  vec2 z = z0;
  for(int i = 0; i < iterations; i++){
    vec2 cz = z;
    for(int j = 1; j < power; j++){
      cz = cp(cz,z);
    }
    z = cz + c;
  }
  return z;
}

void main( void )
{
  vec2 mouse = normalizeScreenCoords(u_mouse.xy) + 0.5;
  vec2 coord = normalizeScreenCoords(gl_FragCoord.xy) * 0.7;
  coord += vec2(0.01,-0.01) * (mouse - 0.5);

  float t = u_time + 20.0;
  vec2 params =
    0.005 * vec2(sin(t * 2.0),cos(t * 2.0)) +
    vec2(-0.20, 0.70) +
    vec2(sin(t * 0.26), cos(t * 0.2)) * vec2(0.02,-0.1) +
    mouse * 0.1;
  vec2 julia = fractal(coord, params);
  // vec2 mandelbrot = fractal(vec2(0.0), coord);
  gl_FragColor = vec4(pseudo(length(julia), 0.0, 1.0), 1.0);
}
