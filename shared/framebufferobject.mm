/*******************************************************************************
    Copyright (c) 2010, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <shared/framebufferobject.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <stdio.h>
#include <stdlib.h>

FramebufferObject::FramebufferObject()
    : width_(0),
      height_(0),
      fbo_id_(0),
      tex_id_(0),
      depthrb_id_(0),
      colorrb_id_(0) {
}

FramebufferObject::~FramebufferObject() {
  if (tex_id_) {
    glDeleteTextures(1, &tex_id_);
    tex_id_ = 0;
  }
  if (colorrb_id_) {
    glDeleteRenderbuffers(1, &colorrb_id_);
    colorrb_id_ = 0;
  }
  if (depthrb_id_) {
    glDeleteRenderbuffers(1, &depthrb_id_);
    depthrb_id_ = 0;
  }
  if (fbo_id_) {
    glDeleteFramebuffers(1, &fbo_id_);
    fbo_id_ = 0;
  }
}

FramebufferObject *FramebufferObject::Create(int width, int height, ColorType color, DepthType depth) {
  FramebufferObject *fbo = new FramebufferObject();
  fbo->width_ = width;
  fbo->height_ = height;
  glGenFramebuffers(1, &fbo->fbo_id_);
  glBindFramebuffer(GL_FRAMEBUFFER, fbo->fbo_id_);
  if (color >= HDR) {
    // Create the HDR render target
    unsigned int format = GL_UNSIGNED_BYTE;
    unsigned int type = GL_RGB;
    switch (color) {
    case RGB16F: type = GL_RGB; format = GL_HALF_FLOAT_OES; break;
    default:
    case RGBA16F: type = GL_RGBA; format = GL_HALF_FLOAT_OES; break;
    }
    glGenTextures(1, &fbo->tex_id_);
    glBindTexture(GL_TEXTURE_2D, fbo->tex_id_);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, type, width, height, 0, type, format, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fbo->tex_id_, 0);
  } else {
    // Create the color render target
    glGenTextures(1, &fbo->tex_id_);
    glBindTexture(GL_TEXTURE_2D, fbo->tex_id_);
    unsigned int internal_format = GL_RGB;
    unsigned int upload_format = GL_UNSIGNED_BYTE;
    switch (color) {
    case RGBA8888: internal_format = GL_RGBA; break;
    default:
    case RGB888: internal_format = GL_RGB; break;
    }
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, internal_format, width, height, 0, GL_RGB, upload_format, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    // Bind color buffer
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fbo->tex_id_, 0);
  }
  // Bind depth buffer
  if (depth != NoDepth) {
    glGenRenderbuffers(1, &fbo->depthrb_id_);
    glBindRenderbuffer(GL_RENDERBUFFER, fbo->depthrb_id_);
    unsigned int depth_format = 0;
    switch (depth) {
    case Depth24: depth_format = GL_DEPTH_COMPONENT24_OES; break;
    default:
    case Depth16: depth_format = GL_DEPTH_COMPONENT16; break;
    }
    glRenderbufferStorage(GL_RENDERBUFFER, depth_format, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, fbo->depthrb_id_);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);    
  }
  // Finalize
  if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
    printf("failed to make complete rtt framebuffer object %x\n", glCheckFramebufferStatus(GL_FRAMEBUFFER));
  }
  glBindFramebuffer(GL_FRAMEBUFFER, 0);
  return fbo;
}

void FramebufferObject::Activate() {
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, &old_fbo_);
  glGetIntegerv(GL_VIEWPORT, old_viewport_);
  glBindFramebuffer(GL_FRAMEBUFFER, fbo_id_); 
  glViewport(0, 0, width_, height_);
}

void FramebufferObject::Deactivate() {
  glBindFramebuffer(GL_FRAMEBUFFER, old_fbo_);
  glViewport(old_viewport_[0], old_viewport_[1], old_viewport_[2], old_viewport_[3]);
}