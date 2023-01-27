#type vert
#version 400 core

layout (location = 0) in vec3 iPos;

out vec3 texCoord;

uniform mat4 u_Projection;
uniform mat4 u_View;

void main() {
    // Apply projection and view matrix
    vec4 currentPos = u_Projection * u_View * vec4(iPos, 1.0f);

    // Having z equal to w will always result in a depth of 1
    gl_Position = vec4(currentPos.x, currentPos.y, currentPos.w, currentPos.w);

    // We want to flip the z axis due to the different coordinate systems (left hand vs right hand)
    texCoord = vec3(iPos.x, iPos.y, -iPos.z);
}

#type frag
#version 400 core

out vec4 fragColor;
in vec3 texCoord;

uniform samplerCube u_Skybox;
uniform float u_Gamma;

void main() {  
    fragColor = texture(u_Skybox, texCoord);
    //fragColor.rgb = pow(fragColor.rgb, vec3(u_Gamma));
}