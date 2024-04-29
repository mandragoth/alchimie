module magia.script.render.camera;

import grimoire;
import magia.core;
import magia.kernel;
import magia.render;
import magia.script.common;

package void loadLibRender_camera(GrModule mod) {
    // Fetch maths types
    GrType vec3Type = grGetNativeType("vec3", [grFloat]);
    GrType vec4iType = grGetNativeType("vec4", [grInt]);

    // Camera types
    GrType cameraType = mod.addNative("Camera", [], "Entity");
    GrType pCameraType = mod.addNative("PerspectiveCamera", [], "Camera");
    GrType oCameraType = mod.addNative("OrthographicCamera", [], "Camera");

    // AudioContext type
    GrType audioContextType = mod.addNative("AudioContext");

    // Camera constructors
    mod.addConstructor(&_newPerspectiveCamera, pCameraType);
    mod.addConstructor(&_newPerspectiveCamera2, pCameraType, [
            grUInt, grUInt, vec3Type, vec3Type, vec3Type
        ]);
    mod.addConstructor(&_newOrthographicCamera, oCameraType);

    // Camera properties
    mod.addProperty(&_getZoom, null, "zoom", cameraType, grFloat);
    mod.addProperty(&_getUp, null, "up", pCameraType, vec3Type);
    mod.addProperty(&_getRight, null, "right", pCameraType, vec3Type);
    mod.addProperty(&_getForward, null, "forward", pCameraType, vec3Type);

    // Camera operations
    mod.addFunction(&_setZoom, "zoom", [cameraType, grFloat]);
    mod.addFunction(&_setViewport, "viewport", [pCameraType, vec4iType]);
    mod.addFunction(&_setForward, "forward", [pCameraType, vec3Type]);

    // Screen operations
    mod.addFunction(&_getScreenWidth, "screenWidth", [], [grInt]);
    mod.addFunction(&_getScreenHeight, "screenHeight", [], [grInt]);
}

private void _newPerspectiveCamera(GrCall call) {
    PerspectiveCamera camera = new PerspectiveCamera(Magia.window.screenWidth,
        Magia.window.screenHeight);
    Magia.addCamera3D(camera);
    call.setNative(camera);
}

private void _newPerspectiveCamera2(GrCall call) {
    uint width = call.getUInt(0);
    uint height = call.getUInt(1);
    vec3f position = cast(vec3f) call.getNative!SVec3f(2);
    vec3f target = cast(vec3f) call.getNative!SVec3f(3);
    vec3f up = cast(vec3f) call.getNative!SVec3f(4);

    PerspectiveCamera camera = new PerspectiveCamera(width, height, position, target, up);
    Magia.addCamera3D(camera);
    call.setNative(camera);
}

private void _newOrthographicCamera(GrCall call) {
    OrthographicCamera camera = new OrthographicCamera(Magia.window.screenWidth,
        Magia.window.screenHeight);
    Magia.addCamera2D(camera);
    call.setNative(camera);
}

private void _getZoom(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    call.setFloat(camera.zoomLevel);
}

private void _getUp(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    call.setNative(svec3(camera.up));
}

private void _getRight(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    call.setNative(svec3(camera.right));
}

private void _getForward(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    call.setNative(svec3(camera.forward));
}

private void _setZoom(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    camera.zoomLevel(call.getFloat(1));
}

private void _setViewport(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    camera.viewport = call.getNative!SVec4i(1);
}

private void _setForward(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    camera.forward = cast(vec3f) call.getNative!SVec3f(1);
}

private void _getScreenWidth(GrCall call) {
    call.setInt(cast(int) Magia.window.screenWidth);
}

private void _getScreenHeight(GrCall call) {
    call.setInt(cast(int) Magia.window.screenHeight);
}
