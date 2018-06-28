#define iterations 30
#define power 2

uniform vec2 iResolution;
uniform vec4 iMouse;
uniform float iTime;
uniform float iScroll;

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

vec3 pseudo_symmetric ( float intensity, float center, float radius)
{
  vec3 color = vec3(0.0,0.0,0.0);

  vec4 cm5 = vec4(0.0,0.1,0.5,0.0);
  vec4 cm4 = vec4(0.0,0.0,1.0,0.1);
  vec4 cm3 = vec4(0.0,1.0,1.0,0.2);
  vec4 cm2 = vec4(0.0,1.0,0.0,0.3);
  vec4 cm1 = vec4(1.0,1.0,0.0,0.4);
  vec4 c0 = vec4(0.0,0.0,0.0,0.5);
  vec4 c1 = vec4(0.0,0.0,1.0,0.6);
  vec4 c2 = vec4(1.0,0.0,1.0,0.7);
  vec4 c3 = vec4(1.0,0.0,0.0,0.8);
  vec4 c4 = vec4(1.0,1.0,0.0,0.9);
  vec4 c5 = vec4(1.0,1.0,1.0,1.0);

  float min = center - radius;
  float max = center + radius;

  if(intensity < min){
    return cm5.rgb;
  }
  if(intensity >= max){
    return c5.rgb;
  }

  float i = clamp((intensity - min) / (max - min), 0.0, 1.0);
  color = color + _pseudo_step(cm5,cm4,i);
  color = color + _pseudo_step(cm4,cm3,i);
  color = color + _pseudo_step(cm3,cm2,i);
  color = color + _pseudo_step(cm2,cm1,i);
  color = color + _pseudo_step(cm1,c0,i);
  color = color + _pseudo_step(c0,c1,i);
  color = color + _pseudo_step(c1,c2,i);
  color = color + _pseudo_step(c2,c3,i);
  color = color + _pseudo_step(c3,c4,i);
  color = color + _pseudo_step(c4,c5,i);
  return color;
}

// =============================================
vec3 pseudo ( float intensity, float min, float max )
{
  vec3 color = vec3(0.0,0.0,0.0);
  vec4 c0 = vec4(1.00, 0.76, 0.00, 0.0);
  vec4 c1 = vec4(1.00, 0.34, 0.20, 0.2);
  vec4 c2 = vec4(0.70, 0.00, 0.22, 0.4);
  vec4 c3 = vec4(0.56, 0.05, 0.24, 0.6);
  vec4 c4 = vec4(0.34, 0.09, 0.27, 0.8);
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
  vec2 res = coords.xy - 0.5 * iResolution.xy;
  return 2.0 * res / min(iResolution.x, iResolution.y);
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
  vec2 mouse = normalizeScreenCoords(iMouse.xy) + 0.5;
  vec2 coord = normalizeScreenCoords(gl_FragCoord.xy) * 0.7;
  coord += vec2(0.01,-0.01) * (mouse - 0.5);

  float t = iTime + 20.0;
  vec2 params = 
    vec2(-0.20, 0.70) + 
    vec2(sin(t * 0.26), cos(t * 0.2)) * vec2(0.02,-0.1) + 
    mouse * 0.02 -
    vec2(0.0,iScroll / iResolution.y);
  vec2 julia = fractal(coord, params);
  // vec2 mandelbrot = fractal(vec2(0.0), coord);
  gl_FragColor = vec4(pseudo(length(julia), 0.0, 1.0), 1.0);
}