module sorcier.script.scamera;

import grimoire;
import magia;

import sorcier.script.common;

void loadAlchimieLibCamera(GrLibDefinition library) {
    // Fetch maths types
    GrType vec3Type = grGetNativeType("vec3", [grFloat]);
    GrType vec4iType = grGetNativeType("vec4", [grInt]);

    // Camera types
    GrType cameraType = library.addNative("Camera", [], "Entity");
    GrType pCameraType = library.addNative("PerspectiveCamera", [], "Camera");
    GrType oCameraType = library.addNative("OrthographicCamera", [], "Camera");

    // Camera constructors
    library.addConstructor(&_newPerspectiveCamera, pCameraType);
    library.addConstructor(&_newPerspectiveCamera2, pCameraType, [
            grUInt, grUInt, vec3Type, vec3Type, vec3Type
        ]);
    library.addConstructor(&_newOrthographicCamera, oCameraType);

    // Camera properties
    library.addProperty(&_getRotation, null, "rotation", cameraType, grFloat);
    library.addProperty(&_getZoom, null, "zoom", cameraType, grFloat);
    library.addProperty(&_getUp, null, "up", pCameraType, vec3Type);
    library.addProperty(&_getRight, null, "right", pCameraType, vec3Type);
    library.addProperty(&_getForward, null, "forward", pCameraType, vec3Type);

    // Camera operations
    library.addFunction(&_getCamera, "getCamera", [grInt], [cameraType]);
    library.addFunction(&_setRotation, "rotation", [cameraType, grFloat]);
    library.addFunction(&_setZoom, "zoom", [cameraType, grFloat]);
    library.addFunction(&_setViewport, "viewport", [pCameraType, vec4iType]);
    library.addFunction(&_setForward, "forward", [pCameraType, vec3Type]);

    // Screen operations
    library.addFunction(&_getScreenWidth, "screenWidth", [], [grInt]);
    library.addFunction(&_getScreenHeight, "screenHeight", [], [grInt]);
}

private void _newPerspectiveCamera(GrCall call) {
    PerspectiveCamera camera = new PerspectiveCamera(window.screenWidth, window.screenHeight);
    renderer.cameras ~= camera;
    call.setNative(camera);
}

private void _newPerspectiveCamera2(GrCall call) {
    uint width = call.getUInt(0);
    uint height = call.getUInt(1);
    vec3 position = cast(vec3) call.getNative!GrVec3f(2);
    vec3 target = cast(vec3) call.getNative!GrVec3f(3);
    vec3 up = cast(vec3) call.getNative!GrVec3f(4);

    PerspectiveCamera camera = new PerspectiveCamera(width, height, position, target, up);

    renderer.cameras ~= camera;
    call.setNative(camera);
}

private void _newOrthographicCamera(GrCall call) {
    OrthographicCamera camera = new OrthographicCamera();
    renderer.cameras ~= camera;
    call.setNative(camera);
}

private void _getCamera(GrCall call) {
    call.setNative(renderer.cameras[call.getInt(0)]);
}

private void _getRotation(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    call.setFloat(camera.zRotation);
}

private void _getZoom(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    call.setFloat(camera.zoomLevel);
}

private void _getUp(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    call.setNative(grVec3(camera.up));
}

private void _getRight(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    call.setNative(grVec3(camera.right));
}

private void _getForward(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    call.setNative(grVec3(camera.forward));
}

private void _setRotation(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    camera.zRotation(call.getFloat(1));
}

private void _setZoom(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    camera.zoomLevel(call.getFloat(1));
}

private void _setViewport(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    camera.viewport = call.getNative!GrVec4i(1);
}

private void _setForward(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    camera.forward = cast(vec3) call.getNative!GrVec3f(1);
}

private void _getScreenWidth(GrCall call) {
    call.setInt(cast(int) window.screenWidth);
}

private void _getScreenHeight(GrCall call) {
    call.setInt(cast(int) window.screenHeight);
}
