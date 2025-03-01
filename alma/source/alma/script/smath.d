module alma.script.smath;

import magia;
import grimoire;

import alma.script.common;

import std.algorithm;
import std.stdio;
import std.random;

package void loadAlchimieLibMath(GrLibDefinition library) {
    // Maths types @TODO matrice dedicated lib
    library.addNative("mat4");

    GrType vec2IType = grGetNativeType("vec2", [grInt]);
    GrType vec2UType = grGetNativeType("vec2", [grUInt]);

    // Maths functions
    library.addFunction(&_uniform01, "uniform01", [], [grFloat]);
    library.addFunction(&_hashvec2i, "hashvec2i", [vec2IType], [grUInt]);
    library.addFunction(&_sortbyvalue, "sortbyvalue", [grList(vec2UType)], []);
}

private void _uniform01(GrCall call) {
    call.setFloat(uniform01!float());
}

const uint primeX = 15823;
const uint primeY = 9737333;

// Note: hash done here to avoid overflow panick
private void _hashvec2i(GrCall call) {
    vec2i data = cast(vec2i) call.getNative!SVec2i(0);
    uint a = cast(uint) data.x * primeX;
    uint b = cast(uint) data.y * primeY;
    call.setUInt(a + b);
}

// Note: sort done here to avoid grimoire implementation
private void _sortbyvalue(GrCall call) {
    SVec2u[] array = call.getList(0).getNatives!SVec2u();
    array.sort!("a.y < b.y");
}