uniform mat4 uni_mvp;

attribute vec3 att_position;

varying vec3 var_direction;

void main() {
  gl_Position = uni_mvp*vec4(att_position, 1);
  var_direction = normalize(att_position);
}

