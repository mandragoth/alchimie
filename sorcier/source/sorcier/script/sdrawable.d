module sorcier.script.sdrawable;

import std.stdio;

import grimoire;
import magia;

import sorcier.script.common;

package void loadAlchimieLibDrawable(GrLibDefinition library) {
    // Maths types
    GrType vec2Type = grGetNativeType("vec2", [grFloat]);
    GrType vec3Type = grGetNativeType("vec3", [grFloat]);
    GrType colorType = grGetNativeType("color");
    GrType vec4iType = grGetNativeType("vec4", [grInt]);

    // Entity types
    GrType instanceType = library.addNative("Instance");
    GrType entityType = library.addNative("Entity", [], "Instance");
    GrType spriteType = library.addNative("Sprite", [], "Entity");
    GrType skyboxType = library.addNative("Skybox", [], "Entity");
    GrType modelType = library.addNative("Model", [], "Entity");
    GrType quadType = library.addNative("Quad", [], "Entity");

    // Entity constructors
    library.addConstructor(&_newSprite, spriteType, [grString]);
    library.addConstructor(&_newSprite2, spriteType, [grString, vec4iType]);
    library.addConstructor(&_newSkybox, skyboxType, [grString]);
    library.addConstructor(&_newModel, modelType, [grString]);
    library.addConstructor(&_newQuad, quadType);

    // Entity operations
    library.addFunction(&_getPosition, "position", [instanceType], [vec3Type]);
    library.addFunction(&_setPosition2D, "position2D", [instanceType, vec2Type]);
    library.addFunction(&_setPosition, "position", [instanceType, vec3Type]);
    library.addFunction(&_setScale, "scale", [instanceType, vec3Type]);
    library.addFunction(&_addTexture, "addTexture", [entityType, grString]);
    library.addFunction(&_scale, "scale", [instanceType, vec3Type]);
    library.addFunction(&_draw, "draw", [entityType]);

    // Entity draw commands
    library.addFunction(&_clear, "clear");
    library.addFunction(&_setup2D, "setup2D");
    library.addFunction(&_setup3D, "setup3D");
    library.addFunction(&_render, "render");
    library.addFunction(&_drawFilledRect, "drawFilledRect", [
            vec2Type, vec2Type, colorType
        ]);
    library.addFunction(&_drawFilledCircle, "drawFilledCircle", [
            vec2Type, grFloat, colorType
        ]);

    // Light types
    GrType directionalLightType = library.addNative("DirectionalLight");
    GrType pointLightType = library.addNative("PointLight", [], "Entity");
    GrType spotLightType = library.addNative("SpotLight", [], "Entity");

    // Light types constructors
    library.addConstructor(&_newDirectionalLight, directionalLightType,
        [vec3Type, grFloat, grFloat]);
    library.addConstructor(&_newPointLight, pointLightType, [
            vec3Type, colorType, grFloat, grFloat
        ]);
    library.addConstructor(&_newSpotLight, spotLightType, [
            vec3Type, vec3Type, colorType, grFloat, grFloat, grFloat
        ]);
}

private void _getPosition(GrCall call) {
    Instance instance = call.getNative!Instance(0);
    call.setNative(grVec3(instance.position));
}

private void _setPosition2D(GrCall call) {
    Instance instance = call.getNative!Instance(0);
    instance.position = cast(vec2) call.getNative!GrVec2f(1);
}

private void _setPosition(GrCall call) {
    Instance instance = call.getNative!Instance(0);
    instance.position = cast(vec3) call.getNative!GrVec3f(1);
}

private void _setScale(GrCall call) {
    Instance instance = call.getNative!Instance(0);
    instance.scale = cast(vec3) call.getNative!GrVec3f(1);
}

private void _addTexture(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Texture texture = fetchPrototype!Texture(call.getString(1));

    if (!entity.material) {
        entity.material = new Material(texture);
    } else {
        entity.material.textures ~= texture;
    }
}

private void _scale(GrCall call) {
    Instance instance = call.getNative!Instance(0);
    instance.scale = cast(vec3) call.getNative!GrVec3f(1);
}

private void _draw(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.draw();
}

private void _newSprite(GrCall call) {
    Sprite sprite = new Sprite(call.getString(0));
    call.setNative(sprite);
}

private void _newSprite2(GrCall call) {
    Sprite sprite = new Sprite(call.getString(0), call.getNative!GrVec4i(1));
    call.setNative(sprite);
}

// @TODO handle currentApplication.scene.addEntity(sprite); and related callbacks

private void _newSkybox(GrCall call) {
    Skybox skybox = new Skybox( /*call.getString(0)*/ );
    call.setNative(skybox);
}

private void _newModel(GrCall call) {
    ModelInstance modelInstance = new ModelInstance(call.getString(0));
    call.setNative(modelInstance);
}

private void _newQuad(GrCall call) {
    QuadInstance quadInstance = new QuadInstance();
    call.setNative(quadInstance);
}

private void _packInstanceMatrix(GrCall call) {
    GrVec4f rotationObj = call.getNative!GrVec4f(1);

    vec3 position = cast(vec3) call.getNative!GrVec3f(0);
    quat rotation = quat(rotationObj.w, rotationObj.x, rotationObj.y, rotationObj.z);
    vec3 scale = cast(vec3) call.getNative!GrVec3f(2);
    mat4 instanceMatrix = combineModel(position, rotation, scale);

    call.setNative(instanceMatrix);
}

private void _clear(GrCall) {
    renderer.clear();
}

private void _setup2D(GrCall) {
    renderer.setup2DRender();
}

private void _setup3D(GrCall) {
    renderer.setup3DRender();
    renderer.setupLights();
}

private void _render(GrCall) {
    currentApplication.render();
}

private void _drawFilledRect(GrCall call) {
    vec2 position = call.getNative!GrVec2f(0);
    vec2 size = call.getNative!GrVec2f(1);
    GrColor color = call.getNative!GrColor(2);

    renderer.drawFilledRect(position, size, color);
}

// @TODO fix this
private void _drawFilledCircle(GrCall call) {
    vec2 position = call.getNative!GrVec2f(0);
    GrColor color = call.getNative!GrColor(2);

    renderer.drawFilledCircle(position, call.getFloat(1), color);
}

private void _newDirectionalLight(GrCall call) {
    DirectionalLight directionalLight = new DirectionalLight();

    directionalLight.direction = call.getNative!GrVec3f(0);
    directionalLight.ambientIntensity = call.getFloat(1);
    directionalLight.diffuseIntensity = call.getFloat(2);

    // Register light in the renderer
    renderer.lightingManager.directionalLight = directionalLight;

    call.setNative(directionalLight);
}

private void _newPointLight(GrCall call) {
    PointLight pointLight = new PointLight();

    pointLight.position = cast(vec3) call.getNative!GrVec3f(0);
    pointLight.color = call.getNative!GrColor(1);
    pointLight.ambientIntensity = call.getFloat(2);
    pointLight.diffuseIntensity = call.getFloat(3);

    // Register light in the renderer
    renderer.lightingManager.addPointLight(pointLight);

    call.setNative(pointLight);
}

private void _newSpotLight(GrCall call) {
    SpotLight spotLight = new SpotLight();

    spotLight.position = cast(vec3) call.getNative!GrVec3f(0);
    spotLight.direction = cast(vec3) call.getNative!GrVec3f(1);
    spotLight.color = call.getNative!GrColor(2);
    spotLight.angle = call.getFloat(3);
    spotLight.ambientIntensity = call.getFloat(4);
    spotLight.diffuseIntensity = call.getFloat(5);

    // Register light in the renderer
    renderer.lightingManager.addSpotLight(spotLight);

    call.setNative(spotLight);
}
