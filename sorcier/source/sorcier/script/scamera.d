module sorcier.script.scamera;

import grimoire;
import magia;

void loadAlchimieLibCamera(GrLibDefinition library) {
    // Fetch maths types
    GrType vec3Type = grGetClassType("vec3");

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
    library.addFunction(&_getUp, "up", [perspectiveCameraType], [vec3Type]);
    library.addFunction(&_getRight, "right", [perspectiveCameraType], [vec3Type]);
    library.addFunction(&_getForward, "forward", [perspectiveCameraType], [vec3Type]);
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

private void _getUp(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    
    GrObject vector = call.createObject("vec3");
    vector.setFloat("x", camera.up.x);
    vector.setFloat("y", camera.up.y);
    vector.setFloat("z", camera.up.z);
    call.setObject(vector);
}

private void _getRight(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    
    GrObject vector = call.createObject("vec3");
    vector.setFloat("x", camera.right.x);
    vector.setFloat("y", camera.right.y);
    vector.setFloat("z", camera.right.z);
    call.setObject(vector);
}

private void _getForward(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    
    GrObject vector = call.createObject("vec3");
    vector.setFloat("x", camera.forward.x);
    vector.setFloat("y", camera.forward.y);
    vector.setFloat("z", camera.forward.z);
    call.setObject(vector);
}