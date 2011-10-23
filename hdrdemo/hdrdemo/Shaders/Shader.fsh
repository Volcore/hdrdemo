//
//  Shader.fsh
//  hdrdemo
//
//  Created by Volker Schoenefeld on 8/8/11.
//  Copyright (c) 2011 Volker Schoenefeld. All rights reserved.
//

varying highp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
