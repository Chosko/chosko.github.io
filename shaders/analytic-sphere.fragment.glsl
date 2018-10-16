#define PI 3.1415926535897932384626433832795
#define NOISE 0.2
#define REFLECTION 0.5
#define NORMAL_MAPPING 0.012
#define NORMAL_SCALE 1.0
#define FRESNEL 0.6
#define FRESNEL_POWER 1.8
#define SPECULAR 0.5
#define AMBIENT 0.1
#define DIFFUSE 0.4

struct Sphere {
    vec4 center;
    float radius;
};

struct Camera {
    mat4 cam2World;
    vec4 origin;
    vec4 target;
    float fov;
};
    
struct Ray {
    vec4 origin;
    vec4 direction;
};
    
struct FragPoint {
    vec4 position;
    vec4 normal;
    vec2 uv;
};

Camera createCamera(vec3 initialOrigin, vec3 target, vec3 up, float fov){
    float dist = length(initialOrigin - target);
    vec2 polar;
    polar.x = 2.0 * PI * iMouse.x/iResolution.x;
    polar.y = PI * iMouse.y/iResolution.y;
    vec3 origin;
    origin.x = dist * sin(polar.y) * cos(polar.x);
    origin.y = dist * cos(polar.y);
    origin.z = dist * sin(polar.y) * sin(polar.x);
    vec3 vz = normalize(origin - target);
    vec3 vx = normalize(cross(up,vz));
    vec3 vy = cross(vz,vx);
    mat4 cam2World;
    cam2World[0] = vec4(vx, 0.0);
    cam2World[1] = vec4(vy, 0.0);
    cam2World[2] = vec4(vz, 0.0);
    cam2World[3] = vec4(origin,1.0);
    return Camera(cam2World, vec4(origin,1.0), vec4(target,1.0), fov);
}
    
Ray castRay(Camera cam, vec2 fragCoord) {
    vec2 pixelNDC = (fragCoord + 0.5) / iResolution.xy;     // Pixel in Normalized Device Coordinates Space   x[0,1] y[0,1]
    vec2 index = floor(pixelNDC);
    pixelNDC = fract(pixelNDC);
    vec2 pixelScreen = pixelNDC * 2.0 - 1.0;			    // Pixel in Screen Space                          x[-1,1] y[-1,1]
    float aspectRatio = iResolution.x / iResolution.y;      // The aspect ratio of the screen space
    vec2 pixelCamera = pixelScreen * vec2(aspectRatio,1.0); // Pixel in Camera Space       x[-aspectRatio,aspectRatio] y[-1,1]
	pixelCamera = pixelCamera * tan(cam.fov / 2.0);         // Pixel in Camera Space, accounting for field of view
    vec4 pointCamera = vec4(pixelCamera,-1.0,1.0);			// Point in Image Plane, related to Camera Space
    
    // Now get the Ray origin and target in world space
    vec4 rayOrigin = cam.origin;
    vec4 rayTarget = cam.cam2World * pointCamera;
    
    return Ray(rayOrigin, normalize(rayTarget-rayOrigin));
}
 
float testSphere(Ray ray, Sphere sph){
    vec4 oc = ray.origin - sph.center; // translate the ray to test against a sphere in the origin
    float a = 1.0;
    float b = dot(2.0 * ray.direction, oc);
    float c = dot(oc,oc) - (sph.radius * sph.radius);
    float delta = b*b-4.0*a*c;
    if (delta < 0.0) return -1.0; // Delta < 0 means no solutions. Return a negative number. It will be ignored.
    return (-b + sign(b)*sqrt(delta))/(2.0*a); // Retrieve only the first solution. If result < 0, the intersection happens behind the camera and it won't be used
}

FragPoint calcSphereFrag(vec4 hit, Sphere sph){
    FragPoint fr;
    fr.position = hit;
    fr.normal = normalize(hit - sph.center);
    fr.uv.x = 0.5 - atan(fr.normal.z,fr.normal.x) / (2.0*PI);
    fr.uv.y = acos(fr.normal.y) / PI;
    return fr;
}

float calcDiffuse(FragPoint fr, vec4 lightDir){
    return max(dot(fr.normal,-lightDir),0.0);
}

float calcSpecular(FragPoint fr, vec4 lightDir, Ray ray, float sharpness){
    vec4 L = -lightDir; // Light direction
	vec4 V = -ray.direction; // View direction
    vec4 H = normalize(L+V); // Half-way vector
    return pow(max(dot(fr.normal,H),0.0),sharpness) * max(dot(fr.normal, L), 0.0);
}

vec4 calcReflection(FragPoint fr, Ray ray, samplerCube cubemap){
    vec4 V = -ray.direction;
    vec4 N = fr.normal;
    float amount = FRESNEL * (pow(1.0-dot(V,N),FRESNEL_POWER));
    vec4 reflectedRay = 2.0*(N - V) + V;
    return (amount + REFLECTION) * texture(cubemap, reflectedRay.xyz);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    // Define the sphere and the camera
    Sphere sph = Sphere(vec4(0.0,0.0,0.0,1.0),1.0); 
    Camera cam = createCamera(vec3(0.0,0.0,3), sph.center.xyz, vec3(0.0,1.0,0.0), PI/4.0);
    vec4 lightDir = normalize(vec4(0.0,-1.0,0.0, 0.0));// Directional light
    
    // Cast a ray from the camera given initial fragment coordinate
    vec2 newCoord = fragCoord;
    Ray ray = castRay(cam, newCoord);
    
    // Test sphere intersection. if t < 0 no useful intersection, or no intersection at all
    float t = testSphere(ray,sph);
    if(t < 0.0){
        fragColor = texture(iChannel3, ray.direction.xyz);
        return;
    }
    
    vec4 hit = ray.origin + t*ray.direction; 		   // Calculate hit point
    FragPoint sFrag = calcSphereFrag(hit, sph);        // Calculate Sphere Fragment
    vec4 texCol = texture(iChannel0, sFrag.uv * 2.0);      // Sample texture color
    vec4 texNoise = texture(iChannel1, sFrag.uv * 6.0);	   // Sample hi-frequency noise
    float noisity = NOISE;
    float normalMapping = NORMAL_MAPPING;
    texCol = texCol * (1.0 - texNoise * noisity);		   // Apply noise
    sFrag.normal.xyz = normalize(sFrag.normal.xyz + normalMapping * dot(sFrag.normal.xyz,texture(iChannel2, sFrag.uv*NORMAL_SCALE).xyz)); // Normal map
    float diffuse = calcDiffuse(sFrag,lightDir) * max(DIFFUSE - AMBIENT,0.0); // Calculate diffuse intensity
    float specular = calcSpecular(sFrag,lightDir,ray,60.0); // Calculate specular intensity
    vec4 reflection = calcReflection(sFrag,ray,iChannel3); // Calculate reflection
    
    fragColor = vec4((AMBIENT + diffuse) * texCol.xyz + specular * SPECULAR + reflection.xyz,1.0);
}