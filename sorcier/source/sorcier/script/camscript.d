module sorcier.script.camscript;

import grimoire;
import magia;

void loadAlchimieLibCamera(GrLibDefinition library) {
    // Camera types
    GrType cameraType = library.addNative("Camera", [], "Entity");
    GrType perspectiveCameraType = library.addNative("PerspectiveCamera", [], "Camera");
    GrType orthographicCameraType = library.addNative("OrthographicCamera", [], "Camera");

    // Camera constructors
    library.addConstructor(&_perspective_camera_new, perspectiveCameraType);
    library.addConstructor(&_orthographic_camera_new, orthographicCameraType);

    // Camera operations
    library.addFunction(&_getCamera, "getCamera", [], [cameraType]);
    library.addFunction(&_getRotation, "rotation", [cameraType], [grFloat]);
    library.addFunction(&_setRotation, "rotation", [cameraType, grFloat]);
    library.addFunction(&_getZoom, "zoom", [cameraType], [grFloat]);
    library.addFunction(&_setZoom, "zoom", [cameraType, grFloat]);
}

private void _perspective_camera_new(GrCall call) {
    PerspectiveCamera camera = new PerspectiveCamera();
    renderer.camera = camera;
    call.setNative(camera);
}

private void _orthographic_camera_new(GrCall call) {
    OrthographicCamera camera = new OrthographicCamera();
    renderer.camera = camera;
    call.setNative(camera);
}

private void _getCamera(GrCall call) {
    call.setNative(renderer.camera);
}

private void _getRotation(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    call.setFloat(camera.zRotation);
}

private void _setRotation(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    camera.zRotation(call.getFloat(1));
}

private void _getZoom(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    call.setFloat(camera.zoomLevel);
}

private void _setZoom(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    camera.zoomLevel(call.getFloat(1));
}