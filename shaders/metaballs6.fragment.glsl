precision highp float;

#define TILING 7.0
#define THRESHOLDS vec2(0.670,1.0)
#define POWERS vec2(0.4, 4.0)
#define TRANSFER vec2(1.0, 0.3)
#define LEVELS vec2(1.0, 255.0)

#define TWOPI 6.28318530718

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

void main() {
  vec3 meta = vec3(0.0,0.0,0.0);

  vec2 uv = transformScreenCoords(gl_FragCoord.xy);
  vec2 m = transformScreenCoords(u_mouse);

  vec3 t = u_time + TWOPI * vec3(0.0, 0.33333, 0.66666);
  t = 0.5 * (sin(t) + 1.0);
  vec3 thresholds = mix(THRESHOLDS.xxx, THRESHOLDS.yyy, t);
  vec3 powers = mix(POWERS.xxx, POWERS.yyy, t);
  vec3 transfer = mix(TRANSFER.xxx, TRANSFER.yyy, t);
  float levels = mix(LEVELS.x, LEVELS.y, 1.0 - pow(0.5 * (sin(u_time * 0.4) + 1.0), 0.03));

  meta.x = fn(uv, 2.5 * vec2(sin(u_time), cos(u_time)), powers.x);
  meta.y = fn(uv, 1.3 * vec2(cos(u_time), sin(u_time)), powers.y);
  meta.z = fn(uv, m, powers.z);

  meta = meta + thresholds - 1.0;

  meta = vec3(
      dot(meta.xyz, transfer),
      dot(meta.yzx, transfer),
      dot(meta.zxy, transfer)
  );

  meta = floor(levels * meta) / levels;

  gl_FragColor = vec4(vec3(meta.rgb), 1.0);
}
