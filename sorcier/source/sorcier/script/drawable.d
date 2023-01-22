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
    GrType vec2Type = library.addClass("vec2", ["x", "y"], [grFloat, grFloat]);
    GrType vec3Type = library.addClass("vec3", ["x", "y", "z"], [grFloat, grFloat, grFloat]);
    GrType vec4iType = library.addClass("vec4i", ["x", "y", "z", "w"], [grInt, grInt, grInt, grInt]);
    GrType quatType = library.addClass("quat", ["w", "x", "y", "z"], [grFloat, grFloat, grFloat, grFloat]);
    GrType mat4Type = library.addNative("mat4");

    GrType entityType = library.addNative("Entity");
    GrType spriteType = library.addNative("Sprite", [], "Entity");

    library.addConstructor(&_vec2_new, vec2Type, [grFloat, grFloat]);
    library.addConstructor(&_vec3_new, vec3Type, [grFloat, grFloat, grFloat]);
    library.addConstructor(&_vec4i_new, vec4iType, [grInt, grInt, grInt, grInt]);
    library.addConstructor(&_quat_new, quatType, [grFloat, grFloat, grFloat, grFloat]);

    library.addFunction(&_position2D, "position", [entityType, vec2Type], []);
    library.addFunction(&_position, "position", [entityType, vec3Type], []);
    library.addFunction(&_scale, "scale", [entityType, vec3Type], []);
    library.addFunction(&_packInstanceMatrix, "packInstanceMatrix", [vec3Type, quatType, vec3Type], [mat4Type]);

    library.addConstructor(&_sprite_new, spriteType, [grString]);
    library.addConstructor(&_sprite_new2, spriteType, [grString, vec4iType]);
}

private void _vec2_new(GrCall call) {
    GrObject v = call.createObject("vec2");
    v.setFloat("x", call.getFloat(0));
    v.setFloat("y", call.getFloat(1));
    call.setObject(v);
}

private void _vec3_new(GrCall call) {
    GrObject v = call.createObject("vec3");
    v.setFloat("x", call.getFloat(0));
    v.setFloat("y", call.getFloat(1));
    v.setFloat("z", call.getFloat(2));
    call.setObject(v);
}

private void _vec4i_new(GrCall call) {
    GrObject v = call.createObject("vec4i");
    v.setFloat("x", call.getFloat(0));
    v.setFloat("y", call.getFloat(1));
    v.setFloat("z", call.getFloat(2));
    v.setFloat("w", call.getFloat(3));
    call.setObject(v);
}

private void _quat_new(GrCall call) {
    GrObject q = call.createObject("quat");
    q.setFloat("w", call.getFloat(0));
    q.setFloat("x", call.getFloat(1));
    q.setFloat("y", call.getFloat(2));
    q.setFloat("z", call.getFloat(3));
    call.setObject(q);
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

    MatWrapper wrapper = new MatWrapper(instanceMatrix);
    call.setNative(wrapper);
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