module magia.script.camera;

import grimoire;
import magia;

package void loadMagiaLibCamera(GrLibrary library) {
    GrType cameraType = library.addNative("Camera");

    library.addFunction(&_camera, "Camera", [], [cameraType]);
    library.addFunction(&_setCamera0, "setCamera");
    library.addFunction(&_setCamera1, "setCamera", [cameraType]);
    library.addFunction(&_getCamera, "getCamera", [], [cameraType]);
    library.addFunction(&_setCameraPosition, "position", [cameraType, grFloat, grFloat, grFloat]);
    library.addFunction(&_getCameraPosition, "position", [cameraType], [grFloat, grFloat, grFloat]);
    /*library.addFunction(&_setCameraOrientation, "orientation", [cameraType, grFloat, grFloat, grFloat]);
    library.addFunction(&_getCameraOrientation, "orientation", [cameraType], [grFloat, grFloat, grFloat]);
    library.addFunction(&_update, "update", [cameraType], []);*/
}

private void _camera(GrCall call) {
    Camera camera_ = new PerspectiveCamera(screenWidth, screenHeight);
    currentApplication.scene.camera = camera_;
    call.setNative(camera_);
}

private void _setCamera0(GrCall) {
    currentApplication.scene.camera = null;
}

private void _setCamera1(GrCall call) {
    currentApplication.scene.camera = call.getNative!Camera(0);
}

private void _getCamera(GrCall call) {
    call.setNative(currentApplication.scene.camera);
}

private void _setCameraPosition(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }

    camera.position = vec3(call.getFloat(1), call.getFloat(2), call.getFloat(3));
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

/*private void _setCameraOrientation(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }

    camera.forward = vec3(call.getFloat(1), call.getFloat(2), call.getFloat(3));
}

private void _getCameraOrientation(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }

    call.setFloat(camera.forward.x);
    call.setFloat(camera.forward.y);
    call.setFloat(camera.forward.z);
}

private void _update(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }

    camera.update();
}*/
