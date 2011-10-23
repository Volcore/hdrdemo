attribute vec2 att_position;
attribute vec4 att_color;

varying vec4 var_color;

void main() {
  gl_Position = vec4(att_position, 0, 1);
  var_color = att_color;
}
