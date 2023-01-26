module sorcier.script.drawable;

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
    library.addConstructor(&_vec2_new, vec2Type, [grFloat, grFloat]);
    library.addConstructor(&_vec3_new, vec3Type, [grFloat, grFloat, grFloat]);
    library.addConstructor(&_color_new, colorType, [grFloat, grFloat, grFloat]);
    library.addConstructor(&_vec4i_new, vec4iType, [grInt, grInt, grInt, grInt]);
    library.addConstructor(&_quat_new, quatType, [grFloat, grFloat, grFloat, grFloat]);

    // Maths operations
    library.addFunction(&_packInstanceMatrix, "packInstanceMatrix", [vec3Type, quatType, vec3Type], [mat4Type]);

    // Entity types
    GrType instanceType = library.addNative("Instance");
    GrType entityType = library.addNative("Entity", [], "Instance");
    GrType spriteType = library.addNative("Sprite", [], "Entity");
    GrType modelType = library.addNative("Model", [], "Entity");

    // Entity constructors
    library.addConstructor(&_sprite_new, spriteType, [grString]);
    library.addConstructor(&_sprite_new2, spriteType, [grString, vec4iType]);
    library.addConstructor(&_model_new, modelType, [grString]);

    // Entity operations
    library.addFunction(&_position2D, "position", [instanceType, vec2Type]);
    library.addFunction(&_position, "position", [instanceType, vec3Type]);
    library.addFunction(&_scale, "scale", [instanceType, vec3Type]);
    library.addFunction(&_draw, "draw", [entityType]);

    // Entity draw commands
    library.addFunction(&_clear, "clear");
    library.addFunction(&_setup2D, "setup2D");
    library.addFunction(&_setup3D, "setup3D");
    library.addFunction(&_render, "render");
    library.addFunction(&_drawFilledRect, "drawFilledRect", [vec2Type, vec2Type, colorType]);
    library.addFunction(&_drawFilledCircle, "drawFilledCircle", [vec2Type, grFloat, colorType]);
}

private void _vec2_new(GrCall call) {
    GrObject vector = call.createObject("vec2");
    vector.setFloat("x", call.getFloat(0));
    vector.setFloat("y", call.getFloat(1));
    call.setObject(vector);
}

private void _vec3_new(GrCall call) {
    GrObject vector = call.createObject("vec3");
    vector.setFloat("x", call.getFloat(0));
    vector.setFloat("y", call.getFloat(1));
    vector.setFloat("z", call.getFloat(2));
    call.setObject(vector);
}

private void _color_new(GrCall call) {
    GrObject color = call.createObject("color");
    color.setFloat("r", call.getFloat(0));
    color.setFloat("g", call.getFloat(1));
    color.setFloat("b", call.getFloat(2));
    call.setObject(color);
}

private void _vec4i_new(GrCall call) {
    GrObject vector = call.createObject("vec4i");
    vector.setFloat("x", call.getFloat(0));
    vector.setFloat("y", call.getFloat(1));
    vector.setFloat("z", call.getFloat(2));
    vector.setFloat("w", call.getFloat(3));
    call.setObject(vector);
}

private void _quat_new(GrCall call) {
    GrObject quat = call.createObject("quat");
    quat.setFloat("w", call.getFloat(0));
    quat.setFloat("x", call.getFloat(1));
    quat.setFloat("y", call.getFloat(2));
    quat.setFloat("z", call.getFloat(3));
    call.setObject(quat);
}

private void _position2D(GrCall call) {
    Instance instance = call.getNative!Instance(0);
    GrObject position = call.getObject(1);
    instance.position = vec2(position.getFloat("x"),
                             position.getFloat("y"));
}

private void _position(GrCall call) {
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

private void _sprite_new(GrCall call) {
    Sprite sprite = new Sprite(call.getString(0));
    currentApplication.scene.addEntity(sprite);
    call.setNative(sprite);
}

private void _sprite_new2(GrCall call) {
    GrObject clipObj = call.getObject(1);
    Sprite sprite = new Sprite(call.getString(0),
        vec4i(clipObj.getInt("x"),
              clipObj.getInt("y"),
              clipObj.getInt("z"),
              clipObj.getInt("w")));
    currentApplication.scene.addEntity(sprite);
    call.setNative(sprite);
}

private void _model_new(GrCall call) {
    Model model = new Model(call.getString(0));
    call.setNative(model);
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

private void _drawFilledCircle(GrCall call) {
    GrObject position = call.getObject(0);
    GrObject color = call.getObject(2);

    renderer.drawFilledCircle(vec2(position.getFloat("x"), position.getFloat("y")),
                              call.getFloat(1),
                              Color(color.getFloat("r"), color.getFloat("g"), color.getFloat("b")));
}