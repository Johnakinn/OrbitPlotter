//
//  Shader.fsh
//  orbitPlotter3
//
//  Created by John Kinn on 7/29/15.
//  Copyright (c) 2015 John Kinn. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 frag_TexCoord;

uniform sampler2D myTexture;

void main()
{
    gl_FragColor = colorVarying * texture2D(myTexture, frag_TexCoord);
}
