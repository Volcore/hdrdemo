/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef SHARED_GLPROGRAM_H_
#define SHARED_GLPROGRAM_H_

#include <shared/codingguides.h>

class GLShader;

typedef int UniformLocation;
typedef int AttributeLocation;

class GLProgram {
 public:
  GLProgram();
  ~GLProgram();
  static GLProgram *FromFiles(const char *vshader_filename, const char *fshader_filename);
  static GLProgram *FromText(const char *vshader, const char *fshader);
  void Attach(const GLShader *shader) const;
  void BindAttribLocation(const char *name, AttributeLocation location) const;
  bool Link() const;
  bool Validate() const;
  void Use() const;
  void Disable() const;
  UniformLocation GetUniformLocation(const char *name) const;
  AttributeLocation GetAttribLocation(const char *name) const;
  void SetUniformi(int uniform, int x) const;
  void SetUniformf(int uniform, float x) const;
  void SetUniformf(int uniform, float x, float y) const;
  void SetUniformf(int uniform, float x, float y, float z) const;
  void SetUniformf(int uniform, float x, float y, float z, float w) const;
  void SetUniformMatrix3(int uniform, const float *m) const;
  void SetUniformMatrix4(int uniform, const float *m) const;
 private:
  unsigned int program_;
  DISALLOW_COPY_AND_ASSIGN(GLProgram);
};

#endif  // SHARED_GLPROGRAM_H_
