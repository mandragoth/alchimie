module sorcier.script.camscript;

import grimoire;
import magia;

void loadAlchimieLibCamera(GrLibDefinition library) {
    // Camera types
    GrType cameraType = library.addNative("Camera");
    GrType perspectiveCameraType = library.addNative("PerspectiveCamera", [], "Camera");
    GrType orthographicCameraType = library.addNative("OrthographicCamera", [], "Camera");

    // Camera constructors
    library.addConstructor(&_perspective_camera_new, perspectiveCameraType);
    library.addConstructor(&_orthographic_camera_new, orthographicCameraType);

    // Camera operations
    library.addFunction(&_getCamera, "getCamera", [], [cameraType]);
    library.addFunction(&_getCameraPosition, "position", [cameraType], [grFloat, grFloat, grFloat]);
    library.addFunction(&_setCameraPosition, "position", [cameraType, grFloat, grFloat, grFloat]);
    library.addFunction(&_getCameraRotation, "rotation", [cameraType], [grFloat]);
    library.addFunction(&_setCameraRotation, "rotation", [cameraType, grFloat]);
    library.addFunction(&_getCameraZoom, "zoom", [cameraType], [grFloat]);
    library.addFunction(&_setCameraZoom, "zoom", [cameraType, grFloat]);
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

private void _getCameraPosition(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    call.setFloat(camera.position.x);
    call.setFloat(camera.position.y);
    call.setFloat(camera.position.z);
}

private void _setCameraPosition(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    camera.position(vec3(call.getFloat(1), call.getFloat(2), call.getFloat(3)));
}

private void _getCameraRotation(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    call.setFloat(camera.zRotation);
}

private void _setCameraRotation(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    camera.zRotation(call.getFloat(1));
}

private void _getCameraZoom(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    call.setFloat(camera.zoomLevel);
}

private void _setCameraZoom(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    camera.zoomLevel(call.getFloat(1));
}