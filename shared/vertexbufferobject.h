/*******************************************************************************
    Copyright (c) 2010, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef SHARED_VERTEXBUFFEROBJECT_H_
#define SHARED_VERTEXBUFFEROBJECT_H_

#include <shared/codingguides.h>
#include <stdint.h>

class VertexBufferObject {
 public:
  VertexBufferObject();
  ~VertexBufferObject();
  void SetVertexData(uint8_t *data, unsigned int length, bool stream=false);
  void SetIndexData(uint8_t *data, unsigned int length, bool stream=false);
  void AddAttribute(int attribute, int count, int type, bool noramlize, int stride, int offset);
  void Draw(unsigned int type, unsigned int count, unsigned int data_type, int offset);
 private:
  unsigned int vbo_id_;
  unsigned int ibo_id_;
  unsigned int vao_id_;
  DISALLOW_COPY_AND_ASSIGN(VertexBufferObject);
};

#endif  // SHARED_VERTEXBUFFEROBJECT_H_
