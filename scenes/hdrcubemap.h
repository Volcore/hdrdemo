/*******************************************************************************
    Copyright (c) 2011, Volker Schoenefeld
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef SCENES_HDRCUBEMAP_H_
#define SCENES_HDRCUBEMAP_H_

#include <shared/codingguides.h>
#include <shared/vertexbufferobject.h>
#include <shared/glprogram.h>

class HDRCubeMap {
 public:
  HDRCubeMap();
  ~HDRCubeMap();
  void Prepare(bool filtering);
  void Draw(float *mvp);
  void Reset();
 private:
  void LoadPFMTexture(const char *const filename, int type);
  GLProgram *program_;
  VertexBufferObject *vbo_;
  unsigned int texid_;
  unsigned int uni_texture_location_;
  unsigned int uni_mvp_location_;
  DISALLOW_COPY_AND_ASSIGN(HDRCubeMap);
};

#endif  // SCENES_HDRCUBEMAP_H_
