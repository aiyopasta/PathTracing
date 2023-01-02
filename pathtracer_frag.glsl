/*
By Aditya Abhyankar, October 2022
*/
#version 410

// Uniform, in, out vars
uniform float time;  // elapsed time in seconds
uniform sampler2D screenTexture;
uniform vec4 camera_data;
in vec3 v_color;
in vec4 v_pos;
out vec4 frag_color;

void main()
{
    vec2 uv = vec2((v_pos.x + 1.0) / 2.0, (-v_pos.y + 1.0) / 2.0);
    vec3 rgb = vec3(0.0);

    if (v_pos.x < 0) {
        rgb = vec3(0.01);
    }

    frag_color = texture(screenTexture, uv) + vec4(rgb, 1.0);
}