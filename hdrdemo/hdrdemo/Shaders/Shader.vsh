//
//  Shader.vsh
//  hdrdemo
//
//  Created by Volker Schoenefeld on 8/8/11.
//  Copyright (c) 2011 Volker Schoenefeld. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

varying vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(4.4, 4.4, 4.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;
    
    gl_Position = modelViewProjectionMatrix * position;
}
