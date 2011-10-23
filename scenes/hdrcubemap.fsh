varying highp vec3 var_direction;
uniform samplerCube uni_texture;

void main() {
  gl_FragColor = textureCube(uni_texture, var_direction);
}
