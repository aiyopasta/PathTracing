/*
By Aditya Abhyankar, October 2022

Note1 : Spherical coords and world coordinates are using mathematician's convention (z-up and theta aziumthal).
Note2 : By default, camera will point in negative world-x direction. In general, it'll point towards world origin.

*/
#version 410
#define PI 3.141592653589793238464338327950288419716939937510582

// Uniform, in, out vars
uniform float time;  // elapsed time in seconds
uniform vec4 camera_data;
in vec3 v_color;
in vec4 v_pos;
out vec4 frag_color;

// Intersect with triangle
vec3 intersect_triangle(vec3 origin, vec3 dir) {
    float halfside = 10.0 / 2.0;
    vec3 v0 = vec3(0, -halfside, -halfside);
    vec3 v1 = vec3(0, halfside, -halfside);
    vec3 v2 = vec3(0, 0, halfside);
    vec3 n = normalize(cross(v1 - v0, v2 - v0));

    // Triangle parallel with ray
    if (dot(n, dir) == 0) {
        return vec3(0.0);
    }

    float t = dot(n, vec3(0, 0, -1000) - origin) / dot(n, dir);
    // Triangle behind the origin
    if (t <= 0) {
        return vec3(0.0);
    }

    // In-out test
    vec3 point = origin + (t * dir);
    bool b0 = dot(cross(v1 - v0, point - v0), n) >= 0;
    bool b1 = dot(cross(v2 - v1, point - v1), n) >= 0;
    bool b2 = dot(cross(v0 - v2, point - v2), n) >= 0;
    return ((b0 && b1) && b2) ? vec3(1.0) : vec3(0.0);
}


void main()  {
    // Parse camera data
    float rho = camera_data.x;
    float theta = camera_data.y;
    float phi = camera_data.z;
    float focus = camera_data.w;  // must be less than rho

    // Set eye position and virtual screen dimensions
    vec3 eye = rho * vec3(sin(phi) * cos(theta), sin(phi) * sin(theta), cos(phi));
    float width = 100.0;  // screen width (in this imaginary world, not actual screen)
    float height = width * 1080 / 1920;

    // Single ray
    vec3 theta_hat = vec3(-sin(theta), cos(theta), 0);
    vec3 phi_hat = -vec3(cos(phi) * cos(theta), cos(phi) * sin(theta), -sin(phi));
    vec3 point = (eye * (focus / rho)) + ((v_pos.x * (width / 2) * theta_hat) + (v_pos.y * (height / 2) * phi_hat));
    vec3 ray_dir = point - eye;

    vec3 rgb = intersect_triangle(eye, point - eye);
    frag_color = vec4(rgb, 1.0);

}