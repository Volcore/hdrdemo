/*******************************************************************************
    Copyright (c) 2010, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <shared/vertexbufferobject.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <stdio.h>

VertexBufferObject::VertexBufferObject()
    : vbo_id_(0),
      ibo_id_(0),
      vao_id_(0) {
  glGenVertexArraysOES(1, &vao_id_);
  glBindVertexArrayOES(vao_id_);
}

VertexBufferObject::~VertexBufferObject() {
  glBindVertexArrayOES(0);
  glDeleteVertexArraysOES(1, &vao_id_);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  glDeleteBuffers(1, &vbo_id_);
  glDeleteBuffers(1, &ibo_id_);
}

void VertexBufferObject::SetVertexData(uint8_t *data, unsigned int length, bool stream) {
  glGenBuffers(1, &vbo_id_);
  glBindBuffer(GL_ARRAY_BUFFER, vbo_id_);
  glBufferData(GL_ARRAY_BUFFER, length, data, stream?GL_STREAM_DRAW:GL_STATIC_DRAW);
}

void VertexBufferObject::SetIndexData(uint8_t *data, unsigned int length, bool stream) {
  glGenBuffers(1, &ibo_id_);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo_id_);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, length, data, stream?GL_STREAM_DRAW:GL_STATIC_DRAW);
}

void VertexBufferObject::AddAttribute(int attribute, int count, int type, bool normalize, int stride, int offset) {
  glEnableVertexAttribArray(attribute);
  glVertexAttribPointer(attribute, count, type, normalize, stride, (GLvoid*)offset);
}

void VertexBufferObject::Draw(unsigned int type, unsigned int count, unsigned int data_type, int offset) {
  glBindVertexArrayOES(vao_id_);
  glDrawElements(type, count, data_type, (GLvoid*)offset);
}
