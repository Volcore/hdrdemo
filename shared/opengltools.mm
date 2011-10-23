/*******************************************************************************
    Copyright (c) 2011, Volker Schoenefeld
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <shared/opengltools.h>

OpenGLTools::OpenGLTools() {
}

OpenGLTools::~OpenGLTools() {
}

void OpenGLTools::GetError(const char *const where) {
  int error = glGetError();
  if (error != GL_NO_ERROR) {
    NSLog(@"GL Error in '%s': %X", where, error);
  }
}

static const char *const enumToString(int e) {
  switch (e) {
#define C(x) case x: return #x;
  C(GL_FRONT_FACE)
#undef C
  default:
    break;
  }
  static char tmp[64];
  snprintf(tmp, 64, "Unknown enum 0x%04X", e);
  return tmp;
}

void OpenGLTools::DumpCapabilities() {
  printf("*** OpenGL ES Capabilities Report ***\n");
  printf("glGetString():\n");
  printf("  Vendor:     %s\n", glGetString(GL_VENDOR));
  printf("  Renderer:   %s\n", glGetString(GL_RENDERER));
  printf("  Version:    %s\n", glGetString(GL_VERSION));
  printf("  Extensions:\n%s\n", glGetString(GL_EXTENSIONS));
  printf("glGet*v():\n");
#define F(string) { \
    float tmp = 0.0f; \
    glGetFloatv(string, &tmp); \
    printf("  %50s: %f\n", #string, tmp); \
  }
#define I(string) { \
    int tmp = 0; \
    glGetIntegerv(string, &tmp); \
    printf("  %50s: %i\n", #string, tmp); \
  }
#define E(string) { \
    int tmp = 0; \
    glGetIntegerv(string, &tmp); \
    printf("  %50s: %s\n", #string, enumToString(tmp)); \
  }
  // Start of list
  I(GL_MAX_VERTEX_ATTRIBS)
  I(GL_MAX_VERTEX_UNIFORM_VECTORS)
  I(GL_MAX_VARYING_VECTORS)
  I(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS)
  I(GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS)
  I(GL_MAX_TEXTURE_IMAGE_UNITS)
  I(GL_MAX_FRAGMENT_UNIFORM_VECTORS)
  I(GL_MAX_CUBE_MAP_TEXTURE_SIZE)
  I(GL_MAX_TEXTURE_SIZE)
  I(GL_MAX_VIEWPORT_DIMS)
}