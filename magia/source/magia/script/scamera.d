module magia.script.scamera;

import grimoire;
import magia.core;
import magia.kernel;
import magia.render;

import magia.script.common;

void loadAlchimieLibCamera(GrModule library) {
    // Fetch maths types
    GrType vec3Type = grGetNativeType("vec3", [grFloat]);
    GrType vec4iType = grGetNativeType("vec4", [grInt]);

    // Camera types
    GrType cameraType = library.addNative("Camera", [], "Entity");
    GrType pCameraType = library.addNative("PerspectiveCamera", [], "Camera");
    GrType oCameraType = library.addNative("OrthographicCamera", [], "Camera");

    // AudioContext type
    GrType audioContextType = library.addNative("AudioContext");

    // Camera constructors
    library.addConstructor(&_newPerspectiveCamera, pCameraType);
    library.addConstructor(&_newPerspectiveCamera2, pCameraType, [grUInt, grUInt, vec3Type, vec3Type, vec3Type]);
    library.addConstructor(&_newOrthographicCamera, oCameraType);

    // Camera properties
    library.addProperty(&_getZoom, null, "zoom", cameraType, grFloat);
    library.addProperty(&_getUp, null, "up", pCameraType, vec3Type);
    library.addProperty(&_getRight, null, "right", pCameraType, vec3Type);
    library.addProperty(&_getForward, null, "forward", pCameraType, vec3Type);

    // Camera operations
    library.addFunction(&_setZoom, "zoom", [cameraType, grFloat]);
    library.addFunction(&_setViewport, "viewport", [pCameraType, vec4iType]);
    library.addFunction(&_setForward, "forward", [pCameraType, vec3Type]);

    // Screen operations
    library.addFunction(&_getScreenWidth, "screenWidth", [], [grInt]);
    library.addFunction(&_getScreenHeight, "screenHeight", [], [grInt]);
}

private void _newPerspectiveCamera(GrCall call) {
    PerspectiveCamera camera = new PerspectiveCamera(Magia.window.screenWidth, Magia.window.screenHeight);
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
    OrthographicCamera camera = new OrthographicCamera(Magia.window.screenWidth, Magia.window.screenHeight);
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
