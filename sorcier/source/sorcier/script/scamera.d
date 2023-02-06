module sorcier.script.scamera;

import grimoire;
import magia;

void loadAlchimieLibCamera(GrLibDefinition library) {
    // Fetch maths types
    GrType vec3Type = grGetClassType("vec3");
    GrType vec4iType = grGetClassType("vec4i");

    // Camera types
    GrType cameraType = library.addNative("Camera", [], "Entity");
    GrType pCameraType = library.addNative("PerspectiveCamera", [], "Camera");
    GrType oCameraType = library.addNative("OrthographicCamera", [], "Camera");

    // Camera constructors
    library.addConstructor(&_newPerspectiveCamera, pCameraType);
    library.addConstructor(&_newPerspectiveCamera2, pCameraType, [grInt, grInt, vec3Type, vec3Type, vec3Type]);
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
    uint width = cast(uint)call.getInt(0);
    uint height = cast(uint)call.getInt(1);

    GrObject positionObj = call.getObject(2);
    vec3 position = vec3(positionObj.getFloat("x"),
                         positionObj.getFloat("y"),
                         positionObj.getFloat("z"));

    GrObject targetObj = call.getObject(3);
    vec3 target = vec3(targetObj.getFloat("x"),
                       targetObj.getFloat("y"),
                       targetObj.getFloat("z"));

    GrObject upObj = call.getObject(4);
    vec3 up = vec3(upObj.getFloat("x"),
                   upObj.getFloat("y"),
                   upObj.getFloat("z"));

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
    if (!camera) {
        call.raise("NullError");
        return;
    }
    call.setFloat(camera.zRotation);
}

private void _getZoom(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    call.setFloat(camera.zoomLevel);
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

private void _setRotation(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    camera.zRotation(call.getFloat(1));
}

private void _setZoom(GrCall call) {
    Camera camera = call.getNative!Camera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    camera.zoomLevel(call.getFloat(1));
}

private void _setViewport(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    
    GrObject vector = call.getObject(1);
    camera.viewport = vec4i(vector.getInt("x"),
                            vector.getInt("y"),
                            vector.getInt("z"),
                            vector.getInt("w"));
}

private void _setForward(GrCall call) {
    PerspectiveCamera camera = call.getNative!PerspectiveCamera(0);
    if (!camera) {
        call.raise("NullError");
        return;
    }
    
    GrObject vector = call.getObject(1);
    camera.forward = vec3(vector.getFloat("x"),
                          vector.getFloat("y"),
                          vector.getFloat("z"));
}

private void _getScreenWidth(GrCall call) {
    call.setInt(cast(int)window.screenWidth);
}

private void _getScreenHeight(GrCall call) {
    call.setInt(cast(int)window.screenHeight);
}