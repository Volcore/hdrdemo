//
//  ViewController.m
//  hdrdemo
//
//  Created by Volker Schoenefeld on 8/8/11.
//  Copyright (c) 2011 Volker Schoenefeld. All rights reserved.
//

#import "ViewController.h"
#include <shared/glprogram.h>
#include <shared/framebufferobject.h>
#include <shared/vertexbufferobject.h>
#include <scenes/hdrcubemap.h>
#include <scenes/histogramviz.h>
#include <shared/opengltools.h>

#define BUFFER_OFFSET(i) ((int)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

unsigned short gCubeIndexData[] = {
  0, 1, 2,
  3, 4, 5,
  6, 7, 8, 
  9, 10, 11,
  12, 13, 14,
  15, 16, 17,
  18, 19, 20,
  21, 22, 23,
  24, 25, 26,
  27, 28, 29,
  30, 31, 32, 
  33, 34, 35
};

GLfloat gFBOVertexData[] = {
  -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
  -1.0f,  1.0f, 0.0f, 0.0f, 1.0f,
   1.0f,  1.0f, 0.0f, 1.0f, 1.0f,
   1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
};

unsigned short gFBOIndexData[] = {
  0, 1, 2,
  0, 2, 3
};

static void myglPushGroupMarker(const char *const name) {
  glPushGroupMarkerEXT(strlen(name)+1, name);
}


@interface ViewController () {
    GLProgram *_program;
    GLProgram *_fbo_program;
    GLint _fbo_tex_bind;
    GLint _fbo_lineartonemap_scale;
    GLint _fbo_lineartonemap_bias;
    float _fbo_scale;
    float _fbo_bias;
    FramebufferObject *_fbo;
    VertexBufferObject *_vbo;
    VertexBufferObject *_fbo_vbo;
    
    HDRCubeMap *_hdrcubemap;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix4 _viewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    bool _renderingHDR;
    
    // Histogram stuff
    float _histogramValues[HISTOGRAM_SIZE];
    dispatch_queue_t _histogramQueue;
    bool _histogramActive;
    HistogramViz *_histogramViz;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupHDR;
- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController

@synthesize context = _context;
@synthesize effect = _effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    _fbo_scale = 0.5f;
    _fbo_bias = -0.5f;
    // Prepare histogram buffer
    _histogramQueue = dispatch_queue_create("histogram_queue", 0);
    _histogramActive = false;
    _histogramView.hidden = !_histogramButton.on;
    [self setupGL];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)setupHDR {
  SAFE_DELETE(_fbo);
  FramebufferObject::ColorType colortype = FramebufferObject::RGB888;
  if (_hdrButton.on) {
    colortype = FramebufferObject::RGB16F;
    _renderingHDR = true;
  } else {
    _renderingHDR = false;
  }
  _fbo = FramebufferObject::Create(self.view.bounds.size.width, self.view.bounds.size.height, colortype, FramebufferObject::Depth16);  
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    printf("GL Extensions: %s\n", glGetString(GL_EXTENSIONS));
    
    [self setupHDR];
    
    _fbo_program = GLProgram::FromFiles("FBOShader", "lineartonemap");
    if (_fbo_program) {
      _fbo_program->BindAttribLocation("att_position", ATTRIB_VERTEX);
      _fbo_program->BindAttribLocation("att_texcoord", ATTRIB_TEXCOORD);
      if (_fbo_program->Link() == false) {
        printf("Failed to link program!\n");      
        SAFE_DELETE(_fbo_program);
      }
      _fbo_tex_bind = _fbo_program->GetUniformLocation("texture");
      _fbo_lineartonemap_scale = _fbo_program->GetUniformLocation("scale");
      _fbo_lineartonemap_bias = _fbo_program->GetUniformLocation("bias");
    }
    _program = GLProgram::FromFiles("Shader", "Shader");
    if (_program) {
      _program->BindAttribLocation("position", ATTRIB_VERTEX);
      _program->BindAttribLocation("normal", ATTRIB_NORMAL);
      if (_program->Link() == false) {
        printf("Failed to link program!\n");
        SAFE_DELETE(_program);
      }
    }
    if (_program) {
      uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = _program->GetUniformLocation("modelViewProjectionMatrix");
      uniforms[UNIFORM_NORMAL_MATRIX] = _program->GetUniformLocation("normalMatrix");
    }
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    _vbo = new VertexBufferObject();
    _vbo->SetVertexData(reinterpret_cast<uint8_t*>(gCubeVertexData), sizeof(gCubeVertexData));
    _vbo->SetIndexData(reinterpret_cast<uint8_t*>(gCubeIndexData), sizeof(gCubeIndexData));
    _vbo->AddAttribute(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    _vbo->AddAttribute(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    _fbo_vbo = new VertexBufferObject();
    _vbo->SetVertexData(reinterpret_cast<uint8_t*>(gFBOVertexData), sizeof(gFBOVertexData));
    _vbo->SetIndexData(reinterpret_cast<uint8_t*>(gFBOIndexData), sizeof(gFBOIndexData));
    _vbo->AddAttribute(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(0));
    _vbo->AddAttribute(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(12));

    _hdrcubemap = new HDRCubeMap();
    _hdrcubemap->Prepare([_filterTextures isOn]);
    _histogramViz = new HistogramViz();
    _histogramViz->Prepare(HISTOGRAM_SIZE);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    dispatch_release(_histogramQueue);
    
    SAFE_DELETE(_histogramViz);
    SAFE_DELETE(_hdrcubemap);
    SAFE_DELETE(_fbo);
    SAFE_DELETE(_vbo);
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    SAFE_DELETE(_program);
    SAFE_DELETE(_fbo_program);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    // Compute the model view matrix for the object rendered with ES2
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix = GLKMatrix4GetMatrix3(GLKMatrix4InvertAndTranspose(modelViewMatrix, NULL));
    
    _viewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, baseModelViewMatrix);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Read configuration
    _fbo_scale = [_scaleSlider value];
    _fbo_bias = [_biasSlider value];
    // Start rendering
    myglPushGroupMarker("HDR Rendering");
    // enable rendering to HDR buffer
    _fbo->Activate();
    // Draw the scene
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // render the cube map
    _hdrcubemap->Draw(_viewProjectionMatrix.m);
    // Render the object with GLKit
    [self.effect prepareToDraw];
    _vbo->Draw(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
    // Render the object again with plain ES2
    _program->Use();
    _program->SetUniformMatrix4(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], _modelViewProjectionMatrix.m);
    _program->SetUniformMatrix3(uniforms[UNIFORM_NORMAL_MATRIX], _normalMatrix.m);
    _vbo->Draw(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
    // Optionally read the framebuffer and compute the histogram
    if (_histogramButton.on) {
      if (_histogramActive == false) {
        int width = self.view.bounds.size.width;
        int height = self.view.bounds.size.height;
        __block float *hdrbuffer = new float[width*height*4];
        __block uint8_t *ldrbuffer = new uint8_t[width*height*4];
        myglPushGroupMarker("Histogram");
        // Should use GL_HALF_FLOAT_OES here, but needs additional conversion routine. Letting the driver do that for now.
        if (_renderingHDR) {
          glReadPixels(0, 0, width, height, GL_RGBA, GL_FLOAT, hdrbuffer);
        } else {
          glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, ldrbuffer);
        }
        OpenGLTools::GetError("histogram_read");
        glPopGroupMarkerEXT();
        _histogramActive = true;
        dispatch_async(_histogramQueue, ^{
          //NSLog(@"Running histogram job...");
          // find min max
          float min = FLT_MAX;
          float max = -FLT_MAX;
          int size = width*height;
          bool hdr = _renderingHDR;
          for (int i=0; i<size; ++i) {
            float r, g, b;
            if (hdr) {
              r = hdrbuffer[4*i+0];
              g = hdrbuffer[4*i+1];
              b = hdrbuffer[4*i+2];
            } else {
              r = ldrbuffer[4*i+0]/255.0f;
              g = ldrbuffer[4*i+1]/255.0f;
              b = ldrbuffer[4*i+2]/255.0f;
            }
            float l = 0.2989 * r + 0.5870 * g + 0.1140 * b;
            if (l < min) min = l;
            if (l > max) max = l;
            hdrbuffer[4*i+0] = l; // write back for later use
          }
          // Clean the histogram
          memset(_histogramValues, 0, HISTOGRAM_SIZE*sizeof(float));
          // Build the histogram
          float hmin = 0.0f; // change this to min/max to have a closer-fitting histogram
          float hmax = 5.0f;
          //float hmax = max;
          float diff = hmax-hmin;
          float step = diff/HISTOGRAM_SIZE;
          float increment = 1.0f/float(size);
          for (int i=0; i<size; ++i) {
            float l = hdrbuffer[4*i+0];
            int bin = (l-hmin)/step;
            if (bin < 0) bin = 0;
            if (bin >= HISTOGRAM_SIZE) bin = HISTOGRAM_SIZE-1;
            _histogramValues[bin] += increment;
          }
          float binmax = 0.0f;
          for (int i=0; i<HISTOGRAM_SIZE; ++i) {
            float v = _histogramValues[i];
            if (v > binmax) binmax = v;
          }
          SAFE_DELETE_ARRAY(ldrbuffer);
          SAFE_DELETE_ARRAY(hdrbuffer);
          //NSLog(@"Histogram job done: min %f, max %f", min, max);
          dispatch_async(dispatch_get_main_queue(), ^{
            _histogramMin.text = [NSString stringWithFormat:@"Darkest pixel: %5.3f", min];
            _histogramMax.text = [NSString stringWithFormat:@"Brightest pixel: %5.3f", max];
            _histogramBinMax.text = [NSString stringWithFormat:@"%i%% of pixels", int(100.0*binmax)];
            _histogramUpperBound.text = [NSString stringWithFormat:@"%1.3f", hmax];
          });
          _histogramActive = false;
        });
      }
    }
    // enable rendering to default FB, apply 
    _fbo->Deactivate();
    glPopGroupMarkerEXT();
    myglPushGroupMarker("Tonemapping");
    // Now draw HDR as full-screen quad
    //glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glDisable(GL_DEPTH_TEST);
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    _fbo_program->Use();
    glBindTexture(GL_TEXTURE_2D, _fbo->tex_id());
    _fbo_program->SetUniformi(_fbo_tex_bind, 0);
    _fbo_program->SetUniformf(_fbo_lineartonemap_scale, _fbo_scale, _fbo_scale, _fbo_scale, 1.0f);
    _fbo_program->SetUniformf(_fbo_lineartonemap_bias, _fbo_bias, _fbo_bias, _fbo_bias, 0.0f);
    _fbo_vbo->Draw(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
    glPopGroupMarkerEXT();
    if (_histogramButton.on) {
      myglPushGroupMarker("Histogram Viz");
      _histogramViz->Draw(_histogramValues, self.view.bounds.size.width, self.view.bounds.size.height, _fbo_scale, _fbo_bias);
      glPopGroupMarkerEXT();
    }
}

- (IBAction) toggleHDR {
  [self setupHDR];
}

- (IBAction) toggleHistogram {
  _histogramView.hidden = !_histogramButton.on;
}

- (IBAction) toggleFilterTextures {
    _hdrcubemap->Prepare([_filterTextures isOn]);  
}

@end
