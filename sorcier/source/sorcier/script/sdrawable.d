module sorcier.script.sdrawable;

import std.stdio;

import grimoire;
import magia;

/// Dirty
class MatWrapper {
    /// As heck
    mat4 matrix;

    /// Constructor
    this(mat4 matrix_) {
        matrix = matrix_;
    }
}

package void loadAlchimieLibDrawable(GrLibDefinition library) {
    // Maths types
    GrType vec2Type = library.addClass("vec2", ["x", "y"], [grFloat, grFloat]);
    GrType vec3Type = library.addClass("vec3", ["x", "y", "z"], [grFloat, grFloat, grFloat]);
    GrType colorType = library.addClass("color", ["r", "g", "b"], [grFloat, grFloat, grFloat]);
    GrType vec4iType = library.addClass("vec4i", ["x", "y", "z", "w"], [grInt, grInt, grInt, grInt]);
    GrType quatType = library.addClass("quat", ["w", "x", "y", "z"], [grFloat, grFloat, grFloat, grFloat]);
    GrType mat4Type = library.addNative("mat4");

    // Maths types contructors
    library.addConstructor(&_newVec2, vec2Type, [grFloat, grFloat]);
    library.addConstructor(&_newVec3, vec3Type, [grFloat, grFloat, grFloat]);
    library.addConstructor(&_newColor, colorType, [grFloat, grFloat, grFloat]);
    library.addConstructor(&_newVec4i, vec4iType, [grInt, grInt, grInt, grInt]);
    library.addConstructor(&_newQuat, quatType, [grFloat, grFloat, grFloat, grFloat]);

    // Maths operations
    library.addFunction(&_packInstanceMatrix, "packInstanceMatrix", [vec3Type, quatType, vec3Type], [mat4Type]);

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
    library.addFunction(&_scale, "scale", [instanceType, vec3Type]);
    library.addFunction(&_draw, "draw", [entityType]);

    // Entity draw commands
    library.addFunction(&_clear, "clear");
    library.addFunction(&_setup2D, "setup2D");
    library.addFunction(&_setup3D, "setup3D");
    library.addFunction(&_render, "render");
    library.addFunction(&_drawFilledRect, "drawFilledRect", [vec2Type, vec2Type, colorType]);
    library.addFunction(&_drawFilledCircle, "drawFilledCircle", [vec2Type, grFloat, colorType]);

    // Light types
    GrType directionalLightType = library.addNative("DirectionalLight");
    GrType pointLightType = library.addNative("PointLight", [], "Entity");
    GrType spotLightType = library.addNative("PointLight", [], "Entity");

    // Light types constructors
    library.addConstructor(&_newDirectionalLight, directionalLightType, [vec3Type, grFloat, grFloat]);
    library.addConstructor(&_newPointLight, pointLightType, [vec3Type, colorType, grFloat, grFloat]);
    //library.addConstructor(&_newSpotLight, spotLightType, [vec3Type]);
}

private void _newVec2(GrCall call) {
    GrObject vector = call.createObject("vec2");
    vector.setFloat("x", call.getFloat(0));
    vector.setFloat("y", call.getFloat(1));
    call.setObject(vector);
}

private void _newVec3(GrCall call) {
    GrObject vector = call.createObject("vec3");
    vector.setFloat("x", call.getFloat(0));
    vector.setFloat("y", call.getFloat(1));
    vector.setFloat("z", call.getFloat(2));
    call.setObject(vector);
}

private void _newColor(GrCall call) {
    GrObject color = call.createObject("color");
    color.setFloat("r", call.getFloat(0));
    color.setFloat("g", call.getFloat(1));
    color.setFloat("b", call.getFloat(2));
    call.setObject(color);
}

private void _newVec4i(GrCall call) {
    GrObject vector = call.createObject("vec4i");
    vector.setFloat("x", call.getFloat(0));
    vector.setFloat("y", call.getFloat(1));
    vector.setFloat("z", call.getFloat(2));
    vector.setFloat("w", call.getFloat(3));
    call.setObject(vector);
}

private void _newQuat(GrCall call) {
    GrObject quat = call.createObject("quat");
    quat.setFloat("w", call.getFloat(0));
    quat.setFloat("x", call.getFloat(1));
    quat.setFloat("y", call.getFloat(2));
    quat.setFloat("z", call.getFloat(3));
    call.setObject(quat);
}

private void _getPosition(GrCall call) {
    Instance instance = call.getNative!Instance(0);

    GrObject vector = call.createObject("vec3");
    vector.setFloat("x", instance.position.x);
    vector.setFloat("y", instance.position.y);
    vector.setFloat("z", instance.position.z);

    call.setObject(vector);
}

private void _setPosition2D(GrCall call) {
    Instance instance = call.getNative!Instance(0);
    GrObject position = call.getObject(1);
    instance.position = vec2(position.getFloat("x"),
                             position.getFloat("y"));
}

private void _setPosition(GrCall call) {
    Instance instance = call.getNative!Instance(0);
    GrObject position = call.getObject(1);
    instance.position = vec3(position.getFloat("x"),
                             position.getFloat("y"),
                             position.getFloat("z"));
}

private void _scale(GrCall call) {
    Instance instance = call.getNative!Instance(0);
    GrObject scale = call.getObject(1);
    instance.scale = vec3(scale.getFloat("x"),
                          scale.getFloat("y"),
                          scale.getFloat("z"));
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
    GrObject clipObj = call.getObject(1);
    Sprite sprite = new Sprite(call.getString(0),
        vec4i(clipObj.getInt("x"),
              clipObj.getInt("y"),
              clipObj.getInt("z"),
              clipObj.getInt("w")));
    call.setNative(sprite);
}

// @TODO handle currentApplication.scene.addEntity(sprite); and related callbacks

private void _newSkybox(GrCall call) {
    Skybox skybox = new Skybox(/*call.getString(0)*/);
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
    GrObject positionObj = call.getObject(0);
    GrObject rotationObj = call.getObject(1);
    GrObject scaleObj = call.getObject(2);

    vec3 position = vec3(positionObj.getFloat("x"), positionObj.getFloat("y"),
        positionObj.getFloat("z"));
    quat rotation = quat(rotationObj.getFloat("w"), rotationObj.getFloat("x"),
        rotationObj.getFloat("y"), rotationObj.getFloat("z"));
    vec3 scale = vec3(scaleObj.getFloat("x"), scaleObj.getFloat("y"), scaleObj.getFloat("z"));
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
    GrObject position = call.getObject(0);
    GrObject size = call.getObject(1);
    GrObject color = call.getObject(2);

    renderer.drawFilledRect(vec2(position.getFloat("x"), position.getFloat("y")),
                            vec2(size.getFloat("x"), size.getFloat("y")),
                            Color(color.getFloat("r"), color.getFloat("g"), color.getFloat("b")));
}

// @TODO fix this
private void _drawFilledCircle(GrCall call) {
    GrObject position = call.getObject(0);
    GrObject color = call.getObject(2);

    renderer.drawFilledCircle(vec2(position.getFloat("x"), position.getFloat("y")),
                              call.getFloat(1),
                              Color(color.getFloat("r"), color.getFloat("g"), color.getFloat("b")));
}

private void _newDirectionalLight(GrCall call) {
    DirectionalLight directionalLight = new DirectionalLight();

    GrObject direction = call.getObject(0);
    directionalLight.direction = vec3(direction.getFloat("x"),
                                      direction.getFloat("y"),
                                      direction.getFloat("z"));
    directionalLight.ambientIntensity = call.getFloat(1);
    directionalLight.diffuseIntensity = call.getFloat(2);

    // Register light in the renderer
    renderer.lightingManager.directionalLight = directionalLight;

    call.setNative(directionalLight);
}

private void _newPointLight(GrCall call) {
    PointLight pointLight = new PointLight();

    GrObject direction = call.getObject(0);
    pointLight.position = vec3(direction.getFloat("x"),
                                      direction.getFloat("y"),
                                      direction.getFloat("z"));
    GrObject color = call.getObject(1);
    pointLight.color = Color(color.getFloat("r"), color.getFloat("g"), color.getFloat("b"));
    pointLight.ambientIntensity = call.getFloat(2);
    pointLight.diffuseIntensity = call.getFloat(3);

    // Register light in the renderer
    renderer.lightingManager.addPointLight(pointLight);

    call.setNative(pointLight);
}