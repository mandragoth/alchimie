module sorcier.script.input;

import magia, grimoire;

import sorcier.script.util;

void loadMagiaLibInput(GrLibrary library) {
    library.addEnum("KeyButton", [__traits(allMembers, InputEventKey.Button)]);
    library.addEnum("MouseButton", [__traits(allMembers, InputEventMouseButton.Button)]);

    GrType inputEventType = library.addNative("InputEvent");
    GrType inputEventKeyType = library.addNative("InputEventKey", [], "InputEvent");
    GrType inputEventMouseType = library.addNative("InputEventMouse", [], "InputEvent");
    GrType inputEventMouseButtonType = library.addNative("InputEventMouseButton", [], "InputEventMouse");
    GrType inputEventMouseWheelType = library.addNative("InputEventMouseWheel", [], "InputEventMouse");
    GrType inputEventMouseMotionType = library.addNative("InputEventMouseMotion", [], "InputEventMouse");
    GrType inputEventTextType = library.addNative("InputEventText", [], "InputEvent");
    GrType inputEventFileType = library.addNative("InputEventFile", [], "InputEvent");

    GrType inputMapType = library.addNative("InputMap");

    library.addCast(&_asString, inputEventType, grString);

}

private void _asString(GrCall call) {
    call.setString(call.getNative!InputEvent(0).prettify());
}
