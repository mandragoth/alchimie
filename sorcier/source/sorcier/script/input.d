module sorcier.script.input;

import magia, grimoire;

import sorcier.script.util;

void loadMagiaLibInput(GrLibrary library) {
    library.addEnum("KeyButton", [__traits(allMembers, KeyButton)]);
    library.addEnum("MouseButton", [__traits(allMembers, MouseButton)]);
    GrType inputEventType = library.addEnum("InputEventType",
        [__traits(allMembers, InputEvent.Type)]);

    GrType inputEvent = library.addNative("InputEvent");

    GrType inputMap = library.addNative("InputMap");

    library.addCast(&_asString, inputEvent, grString);
    library.addProperty(&_type, null, "type", inputEvent, inputEventType);
}

private void _asString(GrCall call) {
    call.setString(call.getNative!InputEvent(0).prettify());
}

private void _type(GrCall call) {
    call.setEnum(call.getNative!InputEvent(0).type);
}
