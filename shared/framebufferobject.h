/*******************************************************************************
    Copyright (c) 2010, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef SHARED_FRAMEBUFFEROBJECT_H_
#define SHARED_FRAMEBUFFEROBJECT_H_

#include <shared/codingguides.h>

class FramebufferObject {
 public:
  enum DepthType {
    Depth24,
    Depth16,
    NoDepth
  };
  enum ColorType {
    RGB888,
    RGBA8888,
    HDR = 1000,
    RG16F,
    RGB16F,
    RGBA16F,
  };
  ~FramebufferObject();
  static FramebufferObject *Create(int width, int height, ColorType color, DepthType depth);
  void Activate();
  void Deactivate();
  unsigned int colorrb_id() const { return colorrb_id_; }
  unsigned int tex_id() const { return tex_id_; }
 private:
  FramebufferObject();
  int width_;
  int height_;
  unsigned int fbo_id_;
  unsigned int tex_id_;
  unsigned int depthrb_id_;
  unsigned int colorrb_id_;
  // Temporary variables used for rendering.
  int old_fbo_;
  int old_viewport_[4];
  DISALLOW_COPY_AND_ASSIGN(FramebufferObject);
};

#endif  // SHARED_FRAMEBUFFEROBJECT_H_
