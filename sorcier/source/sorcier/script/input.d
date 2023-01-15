module sorcier.script.input;

import std.traits;

import magia, grimoire;

import sorcier.script.util;

void loadMagiaLibInput(GrLibrary library) {
    GrType keyButton = library.addEnum("KeyButton", [
            __traits(allMembers, InputEvent.KeyButton.Button)
        ], cast(GrInt[])[EnumMembers!(InputEvent.KeyButton.Button)]);
    GrType mouseButton = library.addEnum("MouseButton", [
            __traits(allMembers, InputEvent.MouseButton.Button)
        ], cast(GrInt[])[EnumMembers!(InputEvent.MouseButton.Button)]);
    GrType inputEventType = library.addEnum("InputEventType",
        [__traits(allMembers, InputEvent.Type)]);

    GrType inputEvent = library.addNative("InputEvent");
    GrType inputEventKeyButton = library.addNative("InputEventKeyButton");
    GrType inputEventMouseButton = library.addNative("InputEventMouseButton");
    GrType inputEventMouseMotion = library.addNative("InputEventMouseMotion");
    GrType inputEventMouseWheel = library.addNative("InputEventMouseWheel");
    GrType inputEventTextInput = library.addNative("InputEventTextInput");
    GrType inputEventDropFile = library.addNative("InputEventDropFile");

    GrType inputMap = library.addNative("InputMap");

    // InputEvent
    library.addCast(&_asString, inputEvent, grString);
    library.addProperty(&_type, null, "type", inputEvent, inputEventType);

    library.addProperty(&_keyButton, null, "keyButton", inputEvent,
        grOptional(inputEventKeyButton));
    library.addProperty(&_mouseButton, null, "mouseButton", inputEvent,
        grOptional(inputEventMouseButton));
    library.addProperty(&_mouseMotion, null, "mouseMotion", inputEvent,
        grOptional(inputEventMouseMotion));
    library.addProperty(&_mouseWheel, null, "mouseWheel", inputEvent,
        grOptional(inputEventMouseWheel));
    library.addProperty(&_textInput, null, "textInput", inputEvent,
        grOptional(inputEventTextInput));
    library.addProperty(&_dropFile, null, "dropFile", inputEvent, grOptional(inputEventDropFile));

    library.addFunction(&_accept, "accept", [inputEvent]);
    library.addFunction(&_print, "print", [inputEvent]);

    // KeyButton
    library.addProperty(&_KeyButton_button, null, "button", inputEventKeyButton, keyButton);
    library.addProperty(&_KeyButton_pressed, null, "pressed", inputEventKeyButton, grBool);
    library.addProperty(&_KeyButton_isEcho, null, "isEcho", inputEventKeyButton, grBool);

    // MouseButton
    library.addProperty(&_MouseButton_button, null, "button", inputEventMouseButton, keyButton);
    library.addProperty(&_MouseButton_pressed, null, "pressed", inputEventMouseButton, grBool);
    library.addProperty(&_MouseButton_clicks, null, "clicks", inputEventMouseButton, grInt);
    library.addProperty(&_MouseButton_globalX, null, "globalX", inputEventMouseButton, grInt);
    library.addProperty(&_MouseButton_globalY, null, "globalY", inputEventMouseButton, grInt);
    library.addProperty(&_MouseButton_x, null, "x", inputEventMouseButton, grInt);
    library.addProperty(&_MouseButton_y, null, "y", inputEventMouseButton, grInt);

    // MouseMotion
    library.addProperty(&_MouseMotion_globalX, null, "globalX", inputEventMouseMotion, grInt);
    library.addProperty(&_MouseMotion_globalY, null, "globalY", inputEventMouseMotion, grInt);
    library.addProperty(&_MouseMotion_x, null, "x", inputEventMouseMotion, grInt);
    library.addProperty(&_MouseMotion_y, null, "y", inputEventMouseMotion, grInt);

    // MouseWheel
    library.addProperty(&_MouseWheel_x, null, "x", inputEventMouseWheel, grInt);
    library.addProperty(&_MouseWheel_y, null, "y", inputEventMouseWheel, grInt);

    // TextInput
    library.addProperty(&_TextInput_text, null, "text", inputEventTextInput, grString);

    // DropFile
    library.addProperty(&_DropFile_path, null, "path", inputEventDropFile, grString);

}

private void _asString(GrCall call) {
    call.setString(call.getNative!InputEvent(0).prettify());
}

private void _type(GrCall call) {
    call.setEnum(call.getNative!InputEvent(0).type);
}

private void _keyButton(GrCall call) {
    InputEvent.KeyButton keyButton = call.getNative!InputEvent(0).asKeyButton;
    if (keyButton)
        call.setNative(keyButton);
    else
        call.setNull();
}

private void _mouseButton(GrCall call) {
    InputEvent.MouseButton mouseButton = call.getNative!InputEvent(0).asMouseButton;
    if (mouseButton)
        call.setNative(mouseButton);
    else
        call.setNull();
}

private void _mouseMotion(GrCall call) {
    InputEvent.MouseMotion mouseMotion = call.getNative!InputEvent(0).asMouseMotion;
    if (mouseMotion)
        call.setNative(mouseMotion);
    else
        call.setNull();
}

private void _mouseWheel(GrCall call) {
    InputEvent.MouseWheel mouseWheel = call.getNative!InputEvent(0).asMouseWheel;
    if (mouseWheel)
        call.setNative(mouseWheel);
    else
        call.setNull();
}

private void _textInput(GrCall call) {
    InputEvent.TextInput textInput = call.getNative!InputEvent(0).asTextInput;
    if (textInput)
        call.setNative(textInput);
    else
        call.setNull();
}

private void _dropFile(GrCall call) {
    InputEvent.DropFile dropFile = call.getNative!InputEvent(0).asDropFile;
    if (dropFile)
        call.setNative(dropFile);
    else
        call.setNull();
}

private void _accept(GrCall call) {
    call.getNative!InputEvent(0).accept();
}

private void _print(GrCall call) {
    print(call.getNative!InputEvent(0).prettify());
}

// KeyButton

private void _KeyButton_button(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.KeyButton)(0).button);
}

private void _KeyButton_pressed(GrCall call) {
    call.setBool(call.getNative!(InputEvent.KeyButton)(0).pressed);
}

private void _KeyButton_isEcho(GrCall call) {
    call.setBool(call.getNative!(InputEvent.KeyButton)(0).isEcho);
}

// MouseButton

private void _MouseButton_button(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.MouseButton)(0).button);
}

private void _MouseButton_pressed(GrCall call) {
    call.setBool(call.getNative!(InputEvent.MouseButton)(0).pressed);
}

private void _MouseButton_clicks(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseButton)(0).clicks);
}

private void _MouseButton_globalX(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseButton)(0).globalPosition.x);
}

private void _MouseButton_globalY(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseButton)(0).globalPosition.y);
}

private void _MouseButton_x(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseButton)(0).position.x);
}

private void _MouseButton_y(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseButton)(0).position.y);
}

// MouseButton

private void _MouseMotion_globalX(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseMotion)(0).globalPosition.x);
}

private void _MouseMotion_globalY(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseMotion)(0).globalPosition.y);
}

private void _MouseMotion_x(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseMotion)(0).position.x);
}

private void _MouseMotion_y(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseMotion)(0).position.y);
}

// MouseWheel

private void _MouseWheel_x(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseWheel)(0).wheel.x);
}

private void _MouseWheel_y(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseWheel)(0).wheel.y);
}

// TextInput

private void _TextInput_text(GrCall call) {
    call.setString(call.getNative!(InputEvent.TextInput)(0).text);
}

// DropFile

private void _DropFile_path(GrCall call) {
    call.setString(call.getNative!(InputEvent.DropFile)(0).path);
}
