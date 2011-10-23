//
//  Shader.vsh
//  hdrdemo
//
//  Created by Volker Schoenefeld on 8/8/11.
//  Copyright (c) 2011 Volker Schoenefeld. All rights reserved.
//

attribute vec4 att_position;
attribute vec2 att_texcoord;

varying vec2 var_texcoord;

void main()
{
    gl_Position = att_position;
    var_texcoord = att_texcoord;
}
