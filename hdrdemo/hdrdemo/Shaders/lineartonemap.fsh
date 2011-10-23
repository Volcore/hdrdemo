uniform sampler2D texture;
varying highp vec2 var_texcoord;
uniform highp vec4 scale;
uniform highp vec4 bias;

void main() {
  gl_FragColor = scale*(texture2D(texture, var_texcoord)+bias);
}

