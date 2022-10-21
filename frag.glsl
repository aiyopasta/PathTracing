/*
By Aditya Abhyankar, October 2022

Note1 : Spherical coords and world coordinates are using mathematician's convention (z-up and theta aziumthal).
Note2 : By default, camera will point in negative world-x direction. In general, it'll point towards world origin.

Observation: By default, the specular component has a hard cut-off as we're using a point light. But if you crank
             up the shininess exponent, the specular highlight can become smaller, so the effect is less noticable.

*/
#version 410
#define PI 3.141592653589793238464338327950288419716939937510582

// Uniform, in, out vars
uniform float time;  // elapsed time in seconds
uniform vec4 camera_data;
in vec3 v_color;
in vec4 v_pos;
out vec4 frag_color;

// Intersection Point
struct IntersectionPoint {
    float t;
    vec3 pos;
    vec3 nor;
};

// Intersect with triangle
IntersectionPoint intersect_triangle(vec3 origin, vec3 dir) {
    // Triangle Data
    float halfside = 10.0 / 2.0;
    vec3 v0 = vec3(0, -halfside, -halfside);
    vec3 v1 = vec3(0, halfside, -halfside);
    vec3 v2 = vec3(0, 0, halfside);
    vec3 n = normalize(cross(v1 - v0, v2 - v0));

    // Find intersection...
    IntersectionPoint isect;
    isect.t = -1;

    // Triangle parallel with ray
    if (dot(n, dir) == 0) {
        return isect;
    }

    float t = dot(n, vec3(0, 0, -1000) - origin) / dot(n, dir);
    // Triangle behind the origin
    if (t <= 0) {
        return isect;
    }

    // In-out test
    vec3 point = origin + (t * dir);
    bool b0 = dot(cross(v1 - v0, point - v0), n) >= 0;
    bool b1 = dot(cross(v2 - v1, point - v1), n) >= 0;
    bool b2 = dot(cross(v0 - v2, point - v2), n) >= 0;
    if ((b0 && b1) && b2) {
        isect.t = t;
        isect.pos = point;
        isect.nor = n;
    }
    return isect;
}

// Intersect with sphere
IntersectionPoint intersect_sphere(vec3 origin, vec3 dir) {
    // Circle data
    vec3 center = vec3(0, 0, 0);
    float radius = 7;

    // Find intersection point...
    IntersectionPoint point;
    point.t = -1;

    // Build quadratic
    float A = dot(dir, dir);
    float B = 2 * dot(dir, origin - center);
    float C = dot(origin - center, origin - center) - (radius * radius);
    float disc = (B * B) - (4 * A * C);

    // Solve quadratic
    if (disc < 0) {
        return point;
    }
    float t = min((-B + sqrt(disc)) / (2 * A), (-B - sqrt(disc)) / (2 * A));
    if (t >= 0) {
        point.t = t;
        point.pos = origin + (t * dir);
        point.nor = normalize(point.pos - center);
    }
    return point;
}


void main()  {
    // Parse camera data
    float rho = camera_data.x;
    float theta = camera_data.y;
    float phi = camera_data.z;
    float focus = camera_data.w;  // must be less than rho

    // Point light
    vec3 light_pos = 20 * vec3(1.0);
    vec3 light_col = vec3(1.0, 0.0, 0.0);
    vec3 ambient_col = vec3(0.0, 0.0, 1.0);

    // Set eye position and virtual screen dimensions
    vec3 eye = rho * vec3(sin(phi) * cos(theta), sin(phi) * sin(theta), cos(phi));
    float width = 100.0;  // screen width (in this imaginary world, not actual screen)
    float height = width * 1080 / 1920;

    // Single ray
    vec3 theta_hat = vec3(-sin(theta), cos(theta), 0);
    vec3 phi_hat = -vec3(cos(phi) * cos(theta), cos(phi) * sin(theta), -sin(phi));
    vec3 point = (eye * (focus / rho)) + ((v_pos.x * (width / 2) * theta_hat) + (v_pos.y * (height / 2) * phi_hat));
    vec3 ray_dir = normalize(point - eye);

    IntersectionPoint isect = intersect_sphere(eye, point - eye);
    vec3 rgb = vec3(0.0);
    if (isect.t != -1) {
        vec3 l = normalize(light_pos - isect.pos);
        vec3 v = normalize(-ray_dir);
        vec3 h = normalize(l + v);
        vec3 n = isect.nor;

        float ambient = 0.3;
        float diffuse = max(dot(n, l), 0);
        float specular = diffuse != 0 ? pow(max(dot(n, h), 0), 50) : 0.0;
        rgb = vec3((0.3 * ambient_col * ambient) + light_col * ((1. * diffuse) + (0.3 * specular)));
    }
    frag_color = vec4(rgb, 1.0);

}