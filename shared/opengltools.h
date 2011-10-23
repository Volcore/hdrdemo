/*******************************************************************************
    Copyright (c) 2011, Volker Schoenefeld
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef SHARED_OPENGLTOOLS_H_
#define SHARED_OPENGLTOOLS_H_

#include <shared/codingguides.h>

class OpenGLTools {
 public:
  OpenGLTools();
  ~OpenGLTools();
  static void GetError(const char *const where);
  static void DumpCapabilities();
 private:
  DISALLOW_COPY_AND_ASSIGN(OpenGLTools);
};

#endif  // SHARED_OPENGLTOOLS_H_
