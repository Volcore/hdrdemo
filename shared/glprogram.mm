/*******************************************************************************
    Copyright (c) 2010, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <stdio.h>
#include <shared/glprogram.h>
#include <shared/glshader.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#define DEBUG_PROGRAM
#define VALIDATE_PROGRAM

GLProgram::GLProgram()
    : program_(0) {
  program_ = glCreateProgram();
}

GLProgram::~GLProgram() {
  glDeleteProgram(program_);
}

GLProgram *GLProgram::FromFiles(const char *vertex_shader_filename, const char *fragment_shader_filename) {
  // Load the vertex shader
  NSString *ns_vertex_shader_filename = [NSString stringWithUTF8String:vertex_shader_filename];
  NSString *vertex_shader_pathname = [[NSBundle mainBundle] pathForResource:ns_vertex_shader_filename ofType:@"vsh"];
  const GLchar *vertex_shader_source;
  vertex_shader_source = (GLchar *)[[NSString stringWithContentsOfFile:vertex_shader_pathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
  GLShader *vertex_shader = 0;
  if (vertex_shader_source) {
    vertex_shader = GLShader::LoadAndCompile(GLShader::VERTEX, vertex_shader_source);
  }
  // Load the fragment shader
  NSString *ns_fragment_shader_filename = [NSString stringWithUTF8String:fragment_shader_filename];
  NSString *fragment_shader_pathname = [[NSBundle mainBundle] pathForResource:ns_fragment_shader_filename ofType:@"fsh"];
  const GLchar *fragment_shader_source;
  fragment_shader_source = (GLchar *)[[NSString stringWithContentsOfFile:fragment_shader_pathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
  GLShader *fragment_shader = 0;
  if (fragment_shader_source) { 
    fragment_shader = GLShader::LoadAndCompile(GLShader::FRAGMENT, fragment_shader_source);
  }
  // Check for valid shaders
  if (!vertex_shader || !fragment_shader) {
    SAFE_DELETE(vertex_shader);
    SAFE_DELETE(fragment_shader);
    return NULL;
  }
  GLProgram *program = new GLProgram();
  program->Attach(vertex_shader);
  program->Attach(fragment_shader);
  SAFE_DELETE(vertex_shader);
  SAFE_DELETE(fragment_shader);
  return program;
}


GLProgram *GLProgram::FromText(const char *vertex_shader_source, const char *fragment_shader_source) {
  GLShader *vertex_shader = GLShader::LoadAndCompile(GLShader::VERTEX, vertex_shader_source);
  GLShader *fragment_shader = GLShader::LoadAndCompile(GLShader::FRAGMENT, fragment_shader_source);
  if (!vertex_shader || !fragment_shader) {
    SAFE_DELETE(vertex_shader);
    SAFE_DELETE(fragment_shader);
    return NULL;
  }
  GLProgram *program = new GLProgram();
  program->Attach(vertex_shader);
  program->Attach(fragment_shader);
  SAFE_DELETE(vertex_shader);
  SAFE_DELETE(fragment_shader);
  return program;
}

void GLProgram::Attach(const GLShader *shader) const {
  glAttachShader(program_, shader->shader());
}

bool GLProgram::Link() const {
  glLinkProgram(program_);
#ifdef DEBUG_PROGRAM
  GLint log_length;
  glGetProgramiv(program_, GL_INFO_LOG_LENGTH, &log_length);
  if (log_length > 0) {
    GLchar *log = new GLchar[log_length];
    glGetProgramInfoLog(program_, log_length, &log_length, log);
    printf("*** Program link log:\n%s", log);
    delete[] log;
  }
#endif
  GLint status;
  glGetProgramiv(program_, GL_LINK_STATUS, &status);
  if (status == 0)
    return false;
  return true;
}

void GLProgram::BindAttribLocation(const char *name, AttributeLocation location) const {
  glBindAttribLocation(program_, location, name);
}

bool GLProgram::Validate() const {
  GLint log_length;
  glValidateProgram(program_);
  glGetProgramiv(program_, GL_INFO_LOG_LENGTH, &log_length);
  if (log_length > 0) {
    GLchar *log = new GLchar[log_length];
    glGetProgramInfoLog(program_, log_length, &log_length, log);
    printf("*** Program validate log:\n%s", log);
    delete []log;
  }
  GLint status;
  glGetProgramiv(program_, GL_VALIDATE_STATUS, &status);
  if (status == 0)
    return false;
  return true;
}

void GLProgram::Use() const {
#ifdef VALIDATE_PROGRAM
  Validate();
#endif
  glUseProgram(program_);
}

void GLProgram::Disable() const {
  glUseProgram(0);
}

UniformLocation GLProgram::GetUniformLocation(const char *name) const {
  return glGetUniformLocation(program_, name);
}

UniformLocation GLProgram::GetAttribLocation(const char *name) const {
  return glGetAttribLocation(program_, name);
}

void GLProgram::SetUniformi(int uniform, int x) const {
  glUniform1i(uniform, x);
}

void GLProgram::SetUniformf(int uniform, float x) const {
  glUniform1f(uniform, x);
}

void GLProgram::SetUniformf(int uniform, float x, float y) const {
  glUniform2f(uniform, x, y);
}

void GLProgram::SetUniformf(int uniform, float x, float y, float z) const {
  glUniform3f(uniform, x, y, z);
}

void GLProgram::SetUniformf(int uniform, float x, float y, float z, float w) const {
  glUniform4f(uniform, x, y, z, w);
}

void GLProgram::SetUniformMatrix3(int uniform, const float *v) const {
  glUniformMatrix3fv(uniform, 1, GL_FALSE, v);
}

void GLProgram::SetUniformMatrix4(int uniform, const float *v) const {
  glUniformMatrix4fv(uniform, 1, GL_FALSE, v);
}
