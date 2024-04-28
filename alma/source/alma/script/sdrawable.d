module alma.script.sdrawable;

import std.stdio;

import grimoire;
import magia;

import alma.script.common;

package void loadAlchimieLibDrawable(GrModule library) {
    // Maths types
    GrType vec2Type = grGetNativeType("vec2", [grFloat]);
    GrType vec3Type = grGetNativeType("vec3", [grFloat]);
    GrType colorType = grGetNativeType("color");
    GrType mat4Type = grGetNativeType("mat4");

    // Entity types
    GrType instanceType = library.addNative("Instance");
    library.addNative("Entity", [], "Instance");
    GrType rectType = library.addNative("Rect", [], "Entity");
    GrType spriteType = library.addNative("Sprite", [], "Entity");
    GrType skyboxType = library.addNative("Skybox", [], "Entity");
    GrType modelType = library.addNative("Model", [], "Entity");
    GrType quadType = library.addNative("Quad", [], "Entity");
    GrType sphereType = library.addNative("Sphere", [], "Entity");

    // Entity constructors
    library.addConstructor(&_newRect, rectType, [grInt, grInt, colorType]);
    library.addConstructor(&_newSprite, spriteType, [grString]);
    library.addConstructor(&_newSkybox, skyboxType, [grString]);
    library.addConstructor(&_newModel, modelType, [grString]);
    library.addConstructor(&_newQuad, quadType);
    library.addConstructor(&_newSphere, sphereType);

    // Instance operations
    library.addFunction(&_getGlobalPosition3D, "globalPosition", [instanceType], [vec3Type]);
    library.addFunction(&_getLocalPosition3D, "localPosition", [instanceType], [vec3Type]);
    library.addFunction(&_setPosition2D, "position", [instanceType, vec2Type]);
    library.addFunction(&_setPosition3D, "position", [instanceType, vec3Type]);
    library.addFunction(&_getRotation3D, "rotation", [instanceType], [vec3Type]);
    library.addFunction(&_setRotation2D, "rotation", [instanceType, grFloat]);
    library.addFunction(&_setRotation3D, "rotation", [instanceType, vec3Type]);
    library.addFunction(&_setScale2D, "scale", [instanceType, vec2Type]);
    library.addFunction(&_setScale3D, "scale", [instanceType, vec3Type]);
    library.addFunction(&_setModel, "model", [instanceType, mat4Type]);
    library.addFunction(&_addChild, "addChild", [instanceType, instanceType]);

    // Entity operations
    library.addFunction(&_addTexture, "addTexture", [modelType, grString]);

    // Light types
    GrType directionalLightType = library.addNative("DirectionalLight");
    GrType pointLightType = library.addNative("PointLight", [], "Entity");
    GrType spotLightType = library.addNative("SpotLight", [], "Entity");

    // Light types constructors
    library.addConstructor(&_newDirectionalLight, directionalLightType, [vec3Type, grFloat, grFloat]);
    library.addConstructor(&_newPointLight, pointLightType, [vec3Type, colorType, grFloat, grFloat]);
    library.addConstructor(&_newSpotLight, spotLightType, [vec3Type, vec3Type, colorType, grFloat, grFloat, grFloat]);

    // Model instances operations
    library.addFunction(&_nbBones, "nbBones", [modelType], [grInt]);
    library.addFunction(&_getDisplayBoneId, "displayBoneId", [modelType], [grInt]);
    library.addFunction(&_setDisplayBoneId, "displayBoneId", [modelType, grInt], []);
}

private void _getGlobalPosition3D(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    call.setNative(toSVec3f(instance.globalPosition));
}

private void _getLocalPosition3D(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    call.setNative(toSVec3f(instance.localPosition));
}

private void _setPosition2D(GrCall call) {
    Instance2D instance = call.getNative!Instance2D(0);
    instance.position = cast(vec2f) call.getNative!SVec2f(1);
}

private void _setPosition3D(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    instance.position = cast(vec3f) call.getNative!SVec3f(1);
}

private void _getRotation3D(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    call.setNative(toSVec3f(instance.transform.rotation.eulerAngles));
}

private void _setRotation2D(GrCall call) {
    Instance2D instance = call.getNative!Instance2D(0);
    instance.rotation = rot2(call.getFloat(1));
}

private void _setRotation3D(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    vec3f eulerAngles = cast(vec3f) call.getNative!SVec3f(1);
    instance.rotation = rot3(eulerAngles);
}

private void _setScale2D(GrCall call) {
    Instance2D instance = call.getNative!Instance2D(0);
    instance.scale = cast(vec2f) call.getNative!SVec2f(1);
}

private void _setScale3D(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    instance.scale = cast(vec3f) call.getNative!SVec3f(1);
}

private void _setModel(GrCall call) {
    Instance3D instance = call.getNative!Instance3D(0);
    instance.model = cast(mat4) call.getNative!SMat4f(1);
}

private void _addChild(GrCall call) {
    Instance3D current = call.getNative!Instance3D(0);
    Instance3D child   = call.getNative!Instance3D(1);
    current.addChild(child);
}

private void _addTexture(GrCall call) {
    ModelInstance modelInstance = call.getNative!ModelInstance(0);
    Texture texture = Magia.res.get!Texture(call.getString(1));
    modelInstance.addTexture(texture);
}

private void _newRect(GrCall call) {
    Rect rect = new Rect(vec2u(call.getInt(0), call.getInt(1)), call.getNative!SColor(2));
    rect.register();
    call.setNative(rect);
}

private void _newSprite(GrCall call) {
    Sprite sprite = Magia.res.get!Sprite(call.getString(0));
    sprite.register();
    call.setNative(sprite);
}

private void _newSkybox(GrCall call) {
    Skybox skybox = Magia.res.get!Skybox(call.getString(0));
    Magia.addDrawable(skybox);
    call.setNative(skybox);
}

private void _newModel(GrCall call) {
    ModelInstance modelInstance = new ModelInstance(call.getString(0));
    Magia.addDrawable(modelInstance);
    call.setNative(modelInstance);
}

private void _newQuad(GrCall call) {
    Quad quad = new Quad();
    call.setNative(quad);
}

private void _newSphere(GrCall call) {
    Sphere sphere = new Sphere(100, 10);
    call.setNative(sphere);
}

private void _newDirectionalLight(GrCall call) {
    DirectionalLight directionalLight = new DirectionalLight();

    directionalLight.direction = cast(vec3f) call.getNative!SVec3f(0);
    directionalLight.ambientIntensity = call.getFloat(1);
    directionalLight.diffuseIntensity = call.getFloat(2);

    // Register light in the renderer
    Magia.light.directionalLight = directionalLight;

    call.setNative(directionalLight);
}

private void _newPointLight(GrCall call) {
    PointLight pointLight = new PointLight();

    pointLight.position = cast(vec3f) call.getNative!SVec3f(0);
    pointLight.color = call.getNative!SColor(1);
    pointLight.ambientIntensity = call.getFloat(2);
    pointLight.diffuseIntensity = call.getFloat(3);

    // Register light in the renderer
    Magia.light.addPointLight(pointLight);

    call.setNative(pointLight);
}

private void _newSpotLight(GrCall call) {
    SpotLight spotLight = new SpotLight();

    spotLight.position = cast(vec3f) call.getNative!SVec3f(0);
    spotLight.direction = cast(vec3f) call.getNative!SVec3f(1);
    spotLight.color = call.getNative!SColor(2);
    spotLight.angle = call.getFloat(3);
    spotLight.ambientIntensity = call.getFloat(4);
    spotLight.diffuseIntensity = call.getFloat(5);

    // Register light in the renderer
    Magia.light.addSpotLight(spotLight);

    call.setNative(spotLight);
}

private void _nbBones(GrCall call) {
    ModelInstance modelInstance = call.getNative!ModelInstance(0);
    call.setInt(modelInstance.nbBones);
}

private void _getDisplayBoneId(GrCall call) {
    ModelInstance modelInstance = call.getNative!ModelInstance(0);
    call.setInt(modelInstance.displayBoneId);
}

private void _setDisplayBoneId(GrCall call) {
    ModelInstance modelInstance = call.getNative!ModelInstance(0);
    modelInstance.displayBoneId = call.getInt(1);
}