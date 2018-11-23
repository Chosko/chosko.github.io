precision highp float;

#define TILING 10.0
#define THRESHOLD 0.9
#define POWER 2.0
#define TRANSFER vec3(2.0,1.0,0.5)

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2 transformScreenCoords(in vec2 uv){
  uv = uv - 0.5 * u_resolution;
  return TILING * uv / min(u_resolution.x, u_resolution.y);
}

float fn(in vec2 uv, in vec2 p) {
  uv = pow(abs(uv - p), vec2(POWER, POWER));
  return 1.0 / (uv.x + uv.y);
}

void main(void) {
  vec3 meta = vec3(0.0,0.0,0.0);

  vec2 uv = transformScreenCoords(gl_FragCoord.xy);
  vec2 m = transformScreenCoords(u_mouse);

  meta.x = fn(uv, 4.0 * vec2(sin(u_time), cos(u_time)));
  meta.y = fn(uv, 2.0 * vec2(cos(u_time), sin(u_time)));
  meta.z = fn(uv, m);

  meta = vec3(
      dot(meta.xyz, TRANSFER),
      dot(meta.yzx, TRANSFER),
      dot(meta.zxy, TRANSFER)
  );

  meta = (meta + THRESHOLD - 1.0);

  gl_FragColor = vec4(vec3(meta), 1.0);
}
