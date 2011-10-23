//
//  Shader.fsh
//  hdrdemo
//
//  Created by Volker Schoenefeld on 8/8/11.
//  Copyright (c) 2011 Volker Schoenefeld. All rights reserved.
//

uniform sampler2D texture;
varying highp vec2 var_texcoord;

void main()
{
    gl_FragColor = 1.25*texture2D(texture, var_texcoord);
}
