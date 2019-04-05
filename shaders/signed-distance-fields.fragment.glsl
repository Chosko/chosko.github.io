#define CAM_DIST 3.0
#define MAX_ITERATIONS 64
#define MAX_DIST 2.688
#define EPSILON 0.001

precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2 transformScreenCoords(in vec2 coords){
  vec2 res = coords.xy - 0.5 * u_resolution.xy;
  return 2.0 * res / min(u_resolution.x, u_resolution.y);
}

float sdSphere ( in vec3 p, in float s ){
  return length (p) - s;
}

float sdTorus ( vec3 p, vec2 t ) {
  vec2 q = vec2 (length(p.xz) - t.x, p.y);
  return length(q) - t.y;
}

float sdScene ( in vec3 p ) {
  return sdSphere (p, 2.0);
}

void main()
{
  vec2 uv = transformScreenCoords(gl_FragCoord.xy);

  vec3 o = vec3(0,0,-CAM_DIST);
  vec3 dir = normalize(vec3(uv, -CAM_DIST + 1.0) - o);
  vec3 p = o;
  float dist = 0.0;

  for (int i = 0; i < MAX_ITERATIONS; i++)
  {
    float de = sdScene ( p );
    dist += de;
    p += dir * de;
    if (de < EPSILON)
      break;
  }

  dist = 1.0 - (p.z - o.z) / MAX_DIST;

  gl_FragColor = vec4(vec3(dist), 1.0);
}
