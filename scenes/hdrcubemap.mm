/*******************************************************************************
    Copyright (c) 2011, Volker Schoenefeld
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <stdio.h>
#include <scenes/hdrcubemap.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <shared/opengltools.h>

static GLfloat gCubeVertexData[] =  {
  -5.0f, -5.0f, -5.0f, // 0
   5.0f, -5.0f, -5.0f, // 1
  -5.0f,  5.0f, -5.0f, // 2
   5.0f,  5.0f, -5.0f, // 3
  -5.0f, -5.0f,  5.0f, // 4
   5.0f, -5.0f,  5.0f, // 5
  -5.0f,  5.0f,  5.0f, // 6
   5.0f,  5.0f,  5.0f, // 7
};

static unsigned short gCubeIndexData[] = {
  0, 1, 2,  2, 1, 3, // xx-
  4, 5, 6,  6, 5, 7, // xx+
  0, 1, 4,  4, 1, 5, // x-x
  2, 3, 6,  6, 3, 7, // x+x
  0, 2, 4,  4, 2, 6, // -xx
  1, 3, 5,  5, 3, 7, // +xx
};


HDRCubeMap::HDRCubeMap()
    : program_(0),
      texid_(0),
      vbo_(0) {
}

HDRCubeMap::~HDRCubeMap() {
  SAFE_DELETE(vbo_);
}

void HDRCubeMap::Reset() {
  if (texid_ != 0) {
    glDeleteTextures(1, &texid_);
  }
  SAFE_DELETE(vbo_);
  SAFE_DELETE(program_);  
}

void HDRCubeMap::LoadPFMTexture(const char *const filename, int type) {
  NSString *ns_filename = [NSString stringWithUTF8String:filename];
  NSString *ns_pathname = [[NSBundle mainBundle] pathForResource:ns_filename ofType:@"pfm"];
  NSData *data = [NSData dataWithContentsOfFile:ns_pathname];
  int width = 256;
  int height = 256;
  void *pixeldata = ((uint8_t*)data.bytes)+21;
  glTexImage2D(type, 0, GL_RGB, width, height, 0, GL_RGB, GL_FLOAT, pixeldata);
  OpenGLTools::GetError("uploadpfm");
}

void HDRCubeMap::Prepare(bool filtering) {
  Reset();
  // load the shader
  program_ = GLProgram::FromFiles("hdrcubemap", "hdrcubemap");
  if (program_) {
    program_->BindAttribLocation("att_position", 0);
    if (program_->Link() == false) {
      printf("Failed to link histogram program!\n");
      SAFE_DELETE(program_);
    } else {
      uni_texture_location_ = program_->GetUniformLocation("uni_texture");
      uni_mvp_location_ = program_->GetUniformLocation("uni_mvp");
    }
  }
  // Build the VBO
  vbo_ = new VertexBufferObject();
  vbo_->SetVertexData(reinterpret_cast<uint8_t*>(gCubeVertexData), sizeof(gCubeVertexData));
  vbo_->SetIndexData(reinterpret_cast<uint8_t*>(gCubeIndexData), sizeof(gCubeIndexData));
  vbo_->AddAttribute(0, 3, GL_FLOAT, GL_FALSE, 12, 0);
  // Load the texture
  glGenTextures(1, &texid_);
  glBindTexture(GL_TEXTURE_CUBE_MAP, texid_);
  if (filtering) {
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  } else {
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  }
  //glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
  glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  OpenGLTools::GetError("pre-uploadpfm");
  LoadPFMTexture("rnl_nx", GL_TEXTURE_CUBE_MAP_NEGATIVE_X);
  LoadPFMTexture("rnl_ny", GL_TEXTURE_CUBE_MAP_NEGATIVE_Y);
  LoadPFMTexture("rnl_nz", GL_TEXTURE_CUBE_MAP_NEGATIVE_Z);
  LoadPFMTexture("rnl_px", GL_TEXTURE_CUBE_MAP_POSITIVE_X);
  LoadPFMTexture("rnl_py", GL_TEXTURE_CUBE_MAP_POSITIVE_Y);
  LoadPFMTexture("rnl_pz", GL_TEXTURE_CUBE_MAP_POSITIVE_Z);
  OpenGLTools::GetError("post-uploadpfm");
  glBindTexture(GL_TEXTURE_2D, 0);  
}

void HDRCubeMap::Draw(float *mvp) {
  //glDisable(GL_DEPTH_TEST);
  //glDepthMask(false);
  glDepthMask(true);
  glEnable(GL_DEPTH_TEST);
  program_->Use();
  glBindTexture(GL_TEXTURE_CUBE_MAP, texid_);
  program_->SetUniformi(uni_texture_location_, 0);
  program_->SetUniformMatrix4(uni_mvp_location_, mvp);
  vbo_->Draw(GL_TRIANGLES, sizeof(gCubeIndexData)/sizeof(unsigned short), GL_UNSIGNED_SHORT, 0);
  glDepthMask(true);
  glEnable(GL_DEPTH_TEST);
}
