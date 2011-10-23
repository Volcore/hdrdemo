/*******************************************************************************
    Copyright (c) 2011, Volker Schoenefeld
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef SCENES_HISTOGRAMVIZ_H_
#define SCENES_HISTOGRAMVIZ_H_

#include <shared/codingguides.h>
#include <shared/glprogram.h>
#include <shared/vertexbufferobject.h>

class HistogramViz {
 public:
  HistogramViz();
  ~HistogramViz();
  void Prepare(int size);
  void Draw(float *histogram, int width, int height, float fbo_scale, float fbo_bias);
 private:
  int histogram_size_;
  GLProgram *program_;
  VertexBufferObject *vbo_;
  VertexBufferObject *vbo2_;
  DISALLOW_COPY_AND_ASSIGN(HistogramViz);
};

#endif  // SCENES_HISTOGRAMVIZ_H_
