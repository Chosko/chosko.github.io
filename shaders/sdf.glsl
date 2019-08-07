precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI				  3.141592653589793
#define TWO_PI			6.283185307179586
#define MAXDIST     10.0
#define THRESHOLD   0.0001
#define DIFF        0.0001
#define ITERATIONS  256
#define BOUNCES     2
#define DISPLACEMENT 0.15
#define TIME        u_time

#define MATSPHERE   0.0
#define MATPLANE    1.0

float hash (in vec3 t) {
  return fract(sin(dot(t, vec3(12.9898, 4.1414, 8.3737))) * 43758.5453);
}

// screen coords to uv
vec2 coords (in vec2 c) {
  return 2.0 * (gl_FragCoord.xy - 0.5 * u_resolution.xy) / min(u_resolution.x, u_resolution.y);
}

// Tiling operator
// in:
//  p -> position
//  t -> tiling extents
// out:
//  d -> repeated position
//  t -> tile index
void opTile (vec3 p, vec3 t, out vec3 d, out vec3 i) {
  d = p / t;
  i = d;
  d = fract (d) * t - t * 0.5;
}

// sky
vec3 background (in vec3 rd) {
  return rd.y * mix(vec3(1.0, 1.0, 1.0), abs(rd + sin(0.2 * TIME)), 1.0 - rd.y);
}

// Sphere sdf
float sphere (in vec3 pos, in float s) {
  return length(pos) - s;
}

// Plane sdf
float plane (in vec3 pos, in vec4 n) {
  return dot(pos, n.xyz) - n.w;
}

// Rounded box sdf
float roundBox(vec3 p, vec3 b, float r)
{
  vec3 d = abs(p) - b;
  return length(max(d,0.0)) - r + min(max(d.x,max(d.y,d.z)),0.0);
}

float tiledGround (vec3 p, vec3 tiling, float cycle) {
  vec3 d, t;

  opTile (p, tiling, d, t);
  d = vec3(d.x, p.y + 1.4, d.z);
  return roundBox (d, vec3(0.19, 0.4 + max(-cos(0.3 + cycle * 0.1) + 0.5, 0.0) * DISPLACEMENT * (sin(cycle * 1.0 + t.x) - cos(cycle * 0.9 + t.z)), 0.19), 0.005);
}

// Map the whole scene using signed distance fields. It returns
// x -> distance from closest object
// y -> material ID
vec2 scene (in vec3 pos) {
  vec2 res = vec2(MAXDIST, -1.0);

  float d = sphere (pos - vec3(0.0, 0.0, 0.0), 1.0);
  if (d < res.x) {
    res = vec2(d, MATSPHERE);
  }

  // d = plane (pos, vec4(0.0, 1.0, 0.0, -1.0));
  // if (d < res.x) {
  //   res = vec2(d, MATPLANE);
  // }

  vec3 tiling = vec3(TWO_PI / 8.0);
  vec3 offset = vec3(0.25, 0.0, -0.25);

  d = tiledGround (pos - tiling * offset.xyz, tiling, TIME + PI);
  if (d < res.x) {
    res = vec2(d, MATPLANE);
  }

  d = tiledGround (pos - tiling * offset.xyx, tiling, TIME + PI + 0.4);
  if (d < res.x) {
    res = vec2(d, MATPLANE);
  }

  d = tiledGround (pos - tiling * offset.zyz, tiling, TIME + PI + 0.2);
  if (d < res.x) {
    res = vec2(d, MATPLANE);
  }

  d = tiledGround (pos - tiling * offset.zyx, tiling, TIME + PI + 0.8);
  if (d < res.x) {
    res = vec2(d, MATPLANE);
  }

  return res;
}

// Ray marching. Returns:
// x -> marched distance
// y -> material of hit object
// z -> number of iterations before hitting an object
vec3 march (in vec3 ro, in vec3 rd) {
  vec3 res = vec3(0.1, -1.0, 0.0);

  for (int i = 0; i < ITERATIONS; i++) {
    vec2 m = scene(ro + rd * res.x);

    res.x += m.x;
    res.y = m.y;
    res.z = float(i);

    if (m.x < THRESHOLD || res.x > MAXDIST)
      break;
  }

  if (res.x > MAXDIST)
    res.y = -1.0;

  return res;
}

// Compute normal using sdf gradient
vec3 calcNormal (in vec3 pos) {
  vec3 diff = vec3(0.0, DIFF, -DIFF);
  return normalize(vec3
  (
    scene (pos + diff.yxx).x - scene(pos + diff.zxx).x,
    scene (pos + diff.xyx).x - scene(pos + diff.xzx).x,
    scene (pos + diff.xxy).x - scene(pos + diff.xxz).x
  ));
}

// Compute material features given the ID
void materials (in float id, in vec3 pos, in vec3 n, out vec3 col, out vec3 reflCol) {
  if (id >= MATPLANE) {
    // Checkerboard pattern
    vec3 t0 = sin(pos * 8.0);
    float t = ceil (0.5 * t0.x * t0.z);
    col = mix(vec3(0.1686, 0.1647, 0.1529), vec3(1.0, 1.0, 1.0), t);
    reflCol = mix(vec3(1.0, 1.0, 1.0), vec3(0.2941, 0.2941, 0.2941), t);
  }
  else if (id >= MATSPHERE) {
    // Radial sections
    float t = ceil(0.5 * sin(32.0 * atan(pos.x, pos.z)));
    col =  mix(vec3(0.5373, 0.7176, 0.9216), vec3(0.3098, 0.4353, 0.6), t);
    reflCol = mix(vec3(0.2275, 0.2275, 0.2275), vec3(0.6941, 0.6941, 0.6941), t);
  }
}

// Compute a directional light and return a color
vec3 dirLight (in vec3 lDir, in vec3 lCol, float lPow, in vec3 pos, in vec3 n, in vec3 rd, in vec3 col, in vec3 reflCol) {
  lDir = normalize(lDir);

  // Hard shadow
  if (march(pos, -lDir).y > -1.0)
    return vec3(0.0);

  float diffuse = max(dot(-lDir,n), 0.0);
  vec3 dRef = reflect (lDir, n);
  float spec = pow(max(dot(dRef, -rd), 0.0), lPow * length(reflCol));

  return
    lCol * diffuse *col +
    lCol * length(reflCol) * spec;
}

// Compute lighting and return a color
vec3 lighting (in vec3 pos, in vec3 n, in vec3 rd, in vec3 col, in vec3 reflCol) {
  // Ambient color
  vec3 ambientColor = vec3(0.302, 0.302, 0.302);

  // Directional light 0
  vec3 l0Dir = vec3(-2.0, -2.0, 1.0);
  vec3 l0Col = vec3(0.5922, 0.7529, 0.7882);
  float l0Pow = 25.0;

  // Directional light 1
  vec3 l1Dir = vec3(3.0, -0.4, -1.0);
  vec3 l1Col = vec3(0.6078, 0.2431, 0.1725);
  float l1Pow = 100.0;

  return
    ambientColor * col +
    dirLight (l0Dir, l0Col, l0Pow, pos, n, rd, col, reflCol) +
    dirLight (l1Dir, l1Col, l1Pow, pos, n, rd, col, reflCol);
}

// Compute camera movements
void transformCamera (inout vec3 ro, inout vec3 rd) {
  // Rotation angle
  float alpha = TIME * 0.2;
  // Camera translation
  vec3 translation = vec3(0.0, -0.5 * sin(TIME * 0.3), sin(TIME * 0.03));

  // Simple rotation and translation
  mat4 t = mat4 (
    cos(alpha), 0, -sin(alpha), translation.x,
    0,          1, 0,           translation.y,
    sin(alpha), 0, cos(alpha),  translation.z,
    0, 0, 0, 0
  );

  // Transform ray
  ro = (vec4(ro, 1.0) * t).xyz;
  rd = (vec4(rd, 0.0) * t).xyz;
}

void main() {
  // Transform screen coords
  vec2 uv = coords (gl_FragCoord.xy);

  // Create ray
  vec3 ro = vec3 (0.0, 0.0, -2.0);
  vec3 rt = ro + vec3(uv, 1.0);
  vec3 rd = normalize(rt - ro);

  // Move and rotate the camera
  transformCamera (ro, rd);

  vec3 outCol = vec3(0);
  vec3 info, pos, n, col, reflCol, lastReflCol;
  lastReflCol = vec3(1);

  // Compute ray bounces. Bounce 0 is the main ray.
  for (int i=0; i < BOUNCES; i++) {
    // March the ray
    info = march (ro, rd);

    // If something was hit
    if (info.y >= 0.0){
      // Compute hit position
      pos = ro + rd * info.x;

      // Compute normal
      n = calcNormal (pos);

      // Extract material properties at hit point
      materials (info.y, pos, n, col, reflCol);

      // Compute color
      outCol +=
        lighting (pos, n, rd, col, reflCol)              // Compute lighting
        * lastReflCol                                    // Apply reflection color (for bounces)
        * (1.0 - pow(info.x / MAXDIST, 4.0))             // Fade over distance
        * pow (1.0 - (info.z / float(ITERATIONS)), 3.0)  // Super simple AO based on number of iterations
        / float(i + 1);                                  // Decrease contribution based on bounce number

      // Prepare next bounce
      ro = pos;               // New ray origin is current hit position
      rd = reflect(rd, n);    // New ray direction is reflection of current ray direction
      lastReflCol = reflCol;  // Keep track of current reflection color to apply it to the next bounce

    }

    // If nothing was hit, compute the sky
    else {
      outCol += lastReflCol * background(rd) / float(i + 1);
      break;
    }
  }

  gl_FragColor = vec4(outCol, 1.0);
}
