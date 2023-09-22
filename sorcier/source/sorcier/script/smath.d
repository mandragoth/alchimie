module sorcier.script.smath;

import magia;
import grimoire;

package void loadAlchimieLibMath(GrLibDefinition library) {
    // Maths types
    GrType quatType = library.addClass("quat", ["w", "x", "y", "z"], [grFloat, grFloat, grFloat, grFloat]);
    library.addNative("mat4");

    // Maths types contructors
    library.addConstructor(&_newQuat, quatType, [grFloat, grFloat, grFloat, grFloat]);
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

private void _newVec2i(GrCall call) {
    GrObject vector = call.createObject("vec2i");
    vector.setFloat("x", call.getFloat(0));
    vector.setFloat("y", call.getFloat(1));
    call.setObject(vector);
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

private void _minusVec3(GrCall call) {
    GrObject v1Obj = call.getObject(0);

    GrObject v2Obj = call.createObject("vec3");
    v2Obj.setFloat("x", -v1Obj.getFloat("x"));
    v2Obj.setFloat("y", -v1Obj.getFloat("y"));
    v2Obj.setFloat("z", -v1Obj.getFloat("z"));

    call.setObject(v2Obj);
}

private void _addVec3(GrCall call) {
    GrObject v1Obj = call.getObject(0);
    GrObject v2Obj = call.getObject(1);

    vec3 v1 = vec3(v1Obj.getFloat("x"), v1Obj.getFloat("y"), v1Obj.getFloat("z"));
    vec3 v2 = vec3(v2Obj.getFloat("x"), v2Obj.getFloat("y"), v2Obj.getFloat("z"));
    vec3 v3 = v1 + v2;

    GrObject v3Obj = call.createObject("vec3");
    v3Obj.setFloat("x", v3.x);
    v3Obj.setFloat("y", v3.y);
    v3Obj.setFloat("z", v3.z);

    call.setObject(v3Obj);
}

private void _scalarVec3(GrCall call) {
    GrObject v1Obj = call.getObject(0);
    vec3 v1 = vec3(v1Obj.getFloat("x"), v1Obj.getFloat("y"), v1Obj.getFloat("z")) * call.getFloat(1);

    GrObject v2Obj = call.createObject("vec3");
    v2Obj.setFloat("x", v1.x);
    v2Obj.setFloat("y", v1.y);
    v2Obj.setFloat("z", v1.z);

    call.setObject(v2Obj);
}

private void _rad(GrCall call) {
    call.setDouble(call.getDouble(0) * degToRad);
}

private void _deg(GrCall call) {
    call.setDouble(call.getDouble(0) * radToDeg);
}

private void _angle(GrCall call) {
    GrObject v1Obj = call.getObject(0);
    GrObject v2Obj = call.getObject(1);

    vec3 v1 = vec3(v1Obj.getFloat("x"), v1Obj.getFloat("y"), v1Obj.getFloat("z"));
    vec3 v2 = vec3(v2Obj.getFloat("x"), v2Obj.getFloat("y"), v2Obj.getFloat("z"));

    call.setFloat(angle(v1, v2));
}

private void _rotate(GrCall call) {
    GrObject v1Obj = call.getObject(0);
    GrObject v2Obj = call.getObject(1);

    vec3 v1 = vec3(v1Obj.getFloat("x"), v1Obj.getFloat("y"), v1Obj.getFloat("z"));
    vec3 v2 = vec3(v2Obj.getFloat("x"), v2Obj.getFloat("y"), v2Obj.getFloat("z"));
    vec3 v3 = rotate(v1, v2, call.getFloat(2));

    GrObject v3Obj = call.createObject("vec3");
    v3Obj.setFloat("x", v3.x);
    v3Obj.setFloat("y", v3.y);
    v3Obj.setFloat("z", v3.z);

    call.setObject(v3Obj);
}

private void _vec2ToString(GrCall call) {
    GrObject vObj = call.getObject(0);
    vec2 vector = vec2(vObj.getFloat("x"), vObj.getFloat("y"));
    call.setString(vector.toString);
}

private void _vec2iToString(GrCall call) {
    GrObject vObj = call.getObject(0);
    vec2i vector = vec2i(vObj.getInt("x"), vObj.getInt("y"));
    call.setString(vector.toString);
}

private void _vec3ToString(GrCall call) {
    GrObject vObj = call.getObject(0);
    vec3 vector = vec3(vObj.getFloat("x"), vObj.getFloat("y"), vObj.getFloat("z"));
    call.setString(vector.toString);
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