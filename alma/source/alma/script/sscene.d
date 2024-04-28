module alma.script.sscene;

import std.stdio;

import grimoire;

import magia.kernel.runtime;
import magia.render.scene;
import alma.script.common;

package void loadAlchimieLibScene(GrModule library) {
    GrType scene2DType = library.addNative("Scene2D");
    GrType scene3DType = library.addNative("Scene3D");

    library.addConstructor(&_newScene2D, scene2DType, []);
    library.addConstructor(&_newScene3D, scene3DType, []);
}

private void _newScene2D(GrCall call) {
    Scene2D scene = new Scene2D(Magia.renderer2D);
    Magia.addCurrentScene(scene);
    call.setNative(scene);
}

private void _newScene3D(GrCall call) {
    Scene3D scene = new Scene3D(Magia.renderer3D);
    Magia.addCurrentScene(scene);
    call.setNative(scene);
}