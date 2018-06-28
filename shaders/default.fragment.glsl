uniform vec2 resolution;
uniform float time;
void main(void)
{
  vec2 uv = gl_FragCoord.xy / resolution.xy;
  gl_FragColor = vec4(uv,0.5+0.5*sin(time),1.0);
}
