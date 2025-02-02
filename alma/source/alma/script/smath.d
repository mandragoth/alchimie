module alma.script.smath;

import magia;
import grimoire;

import std.random;

package void loadAlchimieLibMath(GrLibDefinition library) {
    // Maths types @TODO matrice dedicated lib
    library.addNative("mat4");

    // Maths functions
    library.addFunction(&_uniform01, "uniform01", [], [grFloat]);
}

private void _uniform01(GrCall call) {
    call.setFloat(uniform01!float());
}