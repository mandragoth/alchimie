module alma.script.scamera;

import grimoire;

import alma.kernel;
import alma.script.common;

void loadAlchimieLibCamera(GrLibDefinition library) {
    version(AlmaMagia) {
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
    library.addProperty(&_getRotation, null, "rotation", cameraType, grFloat);
    library.addProperty(&_getZoom, null, "zoom", cameraType, grFloat);
    library.addProperty(&_getUp, null, "up", pCameraType, vec3Type);
    library.addProperty(&_getRight, null, "right", pCameraType, vec3Type);
    library.addProperty(&_getForward, null, "forward", pCameraType, vec3Type);

    // Camera operations
    library.addFunction(&_setRotation, "rotation", [cameraType, grFloat]);
    library.addFunction(&_setZoom, "zoom", [cameraType, grFloat]);
    library.addFunction(&_setViewport, "viewport", [pCameraType, vec4iType]);
    library.addFunction(&_setForward, "forward", [pCameraType, vec3Type]);

    // Screen operations
    library.addFunction(&_getScreenWidth, "screenWidth", [], [grInt]);
    library.addFunction(&_getScreenHeight, "screenHeight", [], [grInt]);
    }
}

version(AlmaMagia):
private void _newPerspectiveCamera(GrCall call) {
    PerspectiveCamera camera = new PerspectiveCamera(Kernel.window.screenWidth, Kernel.window.screenHeight);
    Kernel.addCamera3D(camera);
    call.setNative(camera);
}

private void _newPerspectiveCamera2(GrCall call) {
    uint width = call.getUInt(0);
    uint height = call.getUInt(1);
    vec3 position = cast(vec3) call.getNative!SVec3f(2);
    vec3 target = cast(vec3) call.getNative!SVec3f(3);
    vec3 up = cast(vec3) call.getNative!SVec3f(4);

    PerspectiveCamera camera = new PerspectiveCamera(width, height, position, target, up);
    Kernel.addCamera3D(camera);
    call.setNative(camera);
}
<<<<<<< HEAD
/*
private void _newAudioContext(GrCall call) {
    AudioContext3D context = new AudioContext3D(Kernel.audioDevice, call.getNative!PerspectiveCamera(0));
    Kernel.audioContext = context;
    call.setNative(context);
}*/

private void _newOrthographicCamera(GrCall call) {
    OrthographicCamera camera = new OrthographicCamera();
    Kernel.addCamera2D(camera);
=======

private void _newOrthographicCamera(GrCall call) {
    OrthographicCamera camera = new OrthographicCamera(Magia.window.screenWidth, Magia.window.screenHeight);
    Magia.addCamera2D(camera);
>>>>>>> experimental_runa_kernel
    call.setNative(camera);
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
    call.setNative(toSVec3f(camera.up));
}

private void _getRight(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    call.setNative(toSVec3f(camera.right));
}

private void _getForward(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    call.setNative(toSVec3f(camera.forward));
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
    camera.viewport = call.getNative!SVec4i(1);
}

private void _setForward(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    camera.forward = cast(vec3) call.getNative!SVec3f(1);
}

private void _getScreenWidth(GrCall call) {
    call.setInt(cast(int) Kernel.window.screenWidth);
}

private void _getScreenHeight(GrCall call) {
    call.setInt(cast(int) Kernel.window.screenHeight);
}
