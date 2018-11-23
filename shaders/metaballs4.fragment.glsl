precision highp float;

#define TILING 10.0
#define THRESHOLDS vec3(0.9, 1.0, 1.17)
#define POWERS vec3(1.0, 2.0, 3.0)
#define TRANSFER vec3(1.0,0.5,0.3)
#define LEVELS 5.0

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2 transformScreenCoords(in vec2 uv){
  uv = uv - 0.5 * u_resolution;
  return TILING * uv / min(u_resolution.x, u_resolution.y);
}

float fn(in vec2 uv, in vec2 p, in float power) {
  uv = pow(abs(uv - p), vec2(power, power));
  return 1.0 / (uv.x + uv.y);
}

void main(void) {
  vec3 meta = vec3(0.0,0.0,0.0);

  vec2 uv = transformScreenCoords(gl_FragCoord.xy);
  vec2 m = transformScreenCoords(u_mouse);

  meta.x = fn(uv, 4.0 * vec2(sin(u_time), cos(u_time)), POWERS.x);
  meta.y = fn(uv, 2.0 * vec2(cos(u_time), sin(u_time)), POWERS.y);
  meta.z = fn(uv, m, POWERS.z);

  meta = meta + THRESHOLDS - 1.0;

  meta = vec3(
      dot(meta.xyz, TRANSFER),
      dot(meta.yzx, TRANSFER),
      dot(meta.zxy, TRANSFER)
  );

  meta = floor(LEVELS * meta) / LEVELS;

  gl_FragColor = vec4(vec3(meta.rgb), 1.0);
}
