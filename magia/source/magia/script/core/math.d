module magia.script.core.math;

import grimoire;
import magia.core;

package void loadLibCore_math(GrModule mod) {
    // Maths types
    GrType quatType = mod.addClass("quat", ["w", "x", "y", "z"], [
            grFloat, grFloat, grFloat, grFloat
        ]);
    mod.addNative("mat4");

    // Maths types contructors
    mod.addConstructor(&_newQuat, quatType, [grFloat, grFloat, grFloat, grFloat]);
}

private void _newVec2(GrCall call) {
    GrObject vector = call.createObject("vec2f");
    vector.setFloat("x", call.getFloat(0));
    vector.setFloat("y", call.getFloat(1));
    call.setObject(vector);
}

private void _newVec3(GrCall call) {
    GrObject vector = call.createObject("vec3f");
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

    GrObject v2Obj = call.createObject("vec3f");
    v2Obj.setFloat("x", -v1Obj.getFloat("x"));
    v2Obj.setFloat("y", -v1Obj.getFloat("y"));
    v2Obj.setFloat("z", -v1Obj.getFloat("z"));

    call.setObject(v2Obj);
}

private void _addVec3(GrCall call) {
    GrObject v1Obj = call.getObject(0);
    GrObject v2Obj = call.getObject(1);

    vec3f v1 = vec3f(v1Obj.getFloat("x"), v1Obj.getFloat("y"), v1Obj.getFloat("z"));
    vec3f v2 = vec3f(v2Obj.getFloat("x"), v2Obj.getFloat("y"), v2Obj.getFloat("z"));
    vec3f v3 = v1 + v2;

    GrObject v3Obj = call.createObject("vec3f");
    v3Obj.setFloat("x", v3.x);
    v3Obj.setFloat("y", v3.y);
    v3Obj.setFloat("z", v3.z);

    call.setObject(v3Obj);
}

private void _scalarVec3(GrCall call) {
    GrObject v1Obj = call.getObject(0);
    vec3f v1 = vec3f(v1Obj.getFloat("x"), v1Obj.getFloat("y"), v1Obj.getFloat("z")) *
        call.getFloat(1);

    GrObject v2Obj = call.createObject("vec3f");
    v2Obj.setFloat("x", v1.x);
    v2Obj.setFloat("y", v1.y);
    v2Obj.setFloat("z", v1.z);

    call.setObject(v2Obj);
}

private void _rad(GrCall call) {
    call.setDouble(degToRad(call.getDouble(0)));
}

private void _deg(GrCall call) {
    call.setDouble(radToDeg(call.getDouble(0)));
}

private void _angle(GrCall call) {
    GrObject v1Obj = call.getObject(0);
    GrObject v2Obj = call.getObject(1);

    vec3f v1 = vec3f(v1Obj.getFloat("x"), v1Obj.getFloat("y"), v1Obj.getFloat("z"));
    vec3f v2 = vec3f(v2Obj.getFloat("x"), v2Obj.getFloat("y"), v2Obj.getFloat("z"));

    call.setFloat(angle(v1, v2));
}

private void _rotate(GrCall call) {
    GrObject v1Obj = call.getObject(0);
    GrObject v2Obj = call.getObject(1);

    vec3f v1 = vec3f(v1Obj.getFloat("x"), v1Obj.getFloat("y"), v1Obj.getFloat("z"));
    vec3f v2 = vec3f(v2Obj.getFloat("x"), v2Obj.getFloat("y"), v2Obj.getFloat("z"));
    vec3f v3 = rotate(v1, v2, call.getFloat(2));

    GrObject v3Obj = call.createObject("vec3f");
    v3Obj.setFloat("x", v3.x);
    v3Obj.setFloat("y", v3.y);
    v3Obj.setFloat("z", v3.z);

    call.setObject(v3Obj);
}

private void _vec2ToString(GrCall call) {
    GrObject vObj = call.getObject(0);
    vec2f vector = vec2f(vObj.getFloat("x"), vObj.getFloat("y"));
    call.setString(vector.toString);
}

private void _vec2iToString(GrCall call) {
    GrObject vObj = call.getObject(0);
    vec2i vector = vec2i(vObj.getInt("x"), vObj.getInt("y"));
    call.setString(vector.toString);
}

private void _vec3ToString(GrCall call) {
    GrObject vObj = call.getObject(0);
    vec3f vector = vec3f(vObj.getFloat("x"), vObj.getFloat("y"), vObj.getFloat("z"));
    call.setString(vector.toString);
}
