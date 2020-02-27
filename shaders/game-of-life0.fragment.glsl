precision highp float;

#define TILING 0.5
#define COORD (floor(gl_FragCoord * TILING))
#define RESOLUTION (u_resolution)
#define MOUSE (floor(u_mouse * TILING))

uniform vec2 u_mouse;
uniform vec2 u_resolution;
uniform sampler2D u_buffer0;
uniform float u_time;

  float fetch (int x, int y) {
    return floor (min(1.0, u_time)) * texture2D (u_buffer0, (COORD.xy + vec2(x, y) / TILING) / RESOLUTION).a;
  }

  float evaluate (float sum) {
    float a = 1.0 - floor(abs(clamp(sum - 3.0, -1.0, 1.0)));
    float b = 1.0 - abs(clamp(sum - 2.0, -1.0, 1.0));
    float cur = fetch(0, 0);
    return a + b * cur;
  }

void main()
{
  // BUFFER 0
  #if defined( BUFFER_0 )
  float sum =
    fetch (-1,-1) +
    fetch (-1, 0) +
    fetch (-1, 1) +
    fetch ( 0,-1) +
    fetch ( 0, 1) +
    fetch ( 1,-1) +
    fetch ( 1, 0) +
    fetch ( 1, 1);

  float cursor = min(RESOLUTION.x, RESOLUTION.y) * 0.005;
  if (distance(MOUSE, COORD.xy) < cursor) {
    sum = 2.1;
  }

  sum = evaluate(sum);
  gl_FragColor = vec4(sum, sum, sum, sum);

  // MAIN
  #else
  gl_FragColor = vec4(texture2D(u_buffer0, gl_FragCoord.xy / u_resolution.xy).xyz,1.0);
  #endif
}
