/*******************************************************************************
    Copyright (c) 2011, Volker Schoenefeld
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <stdio.h>
#include <stddef.h>
#include <scenes/histogramviz.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

struct Vertex {
  float x, y;
  uint8_t r, g, b, a;
};

HistogramViz::HistogramViz()
    : program_(0),
      vbo_(0),
      vbo2_(0) {
}

HistogramViz::~HistogramViz() {
  SAFE_DELETE(vbo_);
  SAFE_DELETE(vbo2_);
  SAFE_DELETE(program_);
}

void HistogramViz::Prepare(int size) {
  histogram_size_ = size;
  program_ = GLProgram::FromFiles("histogram", "histogram");
  if (program_) {
    program_->BindAttribLocation("att_position", 0);
    program_->BindAttribLocation("att_color", 1);
    if (program_->Link() == false) {
      printf("Failed to link histogram program!\n");
      SAFE_DELETE(program_);
    }
  }
}

void HistogramViz::Draw(float *histogram, int width, int height, float fbo_scale, float fbo_bias) {
  SAFE_DELETE(vbo_);
  SAFE_DELETE(vbo2_);
  // compute max of histogram
  float max = 0.0f;
  for (int i=0; i<histogram_size_; ++i) {
    if (histogram[i] > max) {
      max = histogram[i];
    }
  }
  float hist_scale = 1.0f/max;
  // Build histogram VBO/IBO
  program_->Use();
  Vertex v[histogram_size_*4];
  Vertex v2[histogram_size_*1];
  unsigned short id[histogram_size_*4];
  unsigned short id2[histogram_size_*1];
  float step_x = 1.0f/float(width);
  float step_y = 1.0f/float(height);
  float start_x = -width+step_x*0.5f;
  float start_y = -height+step_y*0.5f;
  float max_height = 200.0f;
  for (int i=0; i<histogram_size_; ++i) {
    v[4*i+0].x = (start_x+i*2)*step_x;
    v[4*i+0].y = (start_y)*step_y;
    v[4*i+0].r = 255;
    v[4*i+0].g = 255;
    v[4*i+0].b = 255;
    v[4*i+0].a = 255;
    v[4*i+1].x = (start_x+i*2)*step_x;
    v[4*i+1].y = (start_y+histogram[i]*hist_scale*max_height)*step_y;
    v[4*i+1].r = 255;
    v[4*i+1].g = 255;
    v[4*i+1].b = 255;
    v[4*i+1].a = 255;
    v[4*i+2].x = (start_x+i*2)*step_x;
    v[4*i+2].y = (start_y+histogram[i]*hist_scale*max_height)*step_y;
    v[4*i+2].r = 0;
    v[4*i+2].g = 0;
    v[4*i+2].b = 0;
    v[4*i+2].a = 64;
    v[4*i+3].x = (start_x+i*2)*step_x;
    v[4*i+3].y = (start_y+max_height)*step_y;
    v[4*i+3].r = 0;
    v[4*i+3].g = 0;
    v[4*i+3].b = 0;
    v[4*i+3].a = 64;
    // Visualize tonemapping curve
    float hist_x_scale = 5.0f;
    float stm = fbo_scale*(float(i)/histogram_size_*hist_x_scale+fbo_bias);
    if (stm > 1.0f) stm = 1.0f;
    v2[i+0].x = (start_x+i*2)*step_x;
    v2[i+0].y = (start_y+stm*max_height)*step_y;
    v2[i+0].r = 128;
    v2[i+0].g = 255;
    v2[i+0].b = 128;
    v2[i+0].a = 96;
  }
  for (int i=0; i<histogram_size_*4; ++i) {
    id[i] = i;
  }
  for (int i=0; i<histogram_size_*1; ++i) {
    id2[i] = i;
  }
  glLineWidth(2.0f);
  if (vbo_ == 0) {
    vbo_ = new VertexBufferObject();
  }
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  vbo_->SetVertexData((uint8_t*)v, sizeof(v), true);
  vbo_->SetIndexData((uint8_t*)id, sizeof(id), true);
  vbo_->AddAttribute(0, 2, GL_FLOAT, false, sizeof(Vertex), offsetof(Vertex, x));
  vbo_->AddAttribute(1, 4, GL_UNSIGNED_BYTE, true, sizeof(Vertex), offsetof(Vertex, r));
  vbo_->Draw(GL_LINES, histogram_size_*4, GL_UNSIGNED_SHORT, 0);
  vbo_ = new VertexBufferObject();
  if (vbo2_ == 0) {
    vbo2_ = new VertexBufferObject();
  }
  vbo2_->SetVertexData((uint8_t*)v2, sizeof(v2), true);
  vbo2_->SetIndexData((uint8_t*)id2, sizeof(id2), true);
  vbo2_->AddAttribute(0, 2, GL_FLOAT, false, sizeof(Vertex), offsetof(Vertex, x));
  vbo2_->AddAttribute(1, 4, GL_UNSIGNED_BYTE, true, sizeof(Vertex), offsetof(Vertex, r));
  vbo2_->Draw(GL_LINE_STRIP, histogram_size_, GL_UNSIGNED_SHORT, 0);
  glDisable(GL_BLEND);
}
