module sorcier.script.transform;

import grimoire;

import gl3n.linalg;

void loadMagiaLibTransform(GrLibrary library) {
    GrType transformType = library.addNative("Transform");

    library.addFunction(&_position, "position", [transformType], [grFloat, grFloat, grFloat]);
    library.addFunction(&_rotation1, "rotation", [transformType], [grFloat, grFloat, grFloat]);
    library.addFunction(&_rotation2, "rotation", [transformType], [grFloat, grFloat, grFloat]);
    library.addFunction(&_scale, "scale", [transformType], [grFloat, grFloat, grFloat]);
}

private void _position(GrCall call) {
}

private void _rotation1(GrCall call) {
}

private void _rotation2(GrCall call) {
}

private void _scale(GrCall call) {
}