module alma.script.sinput;

import std.traits;

import magia;
import grimoire;

import alma.script.common;

void loadAlchimieLibInput(GrLibDefinition library) {
    GrType keyState = library.addEnum("KeyState", [
            __traits(allMembers, KeyState)
        ], cast(GrInt[])[EnumMembers!(KeyState)]);

    GrType keyButton = library.addEnum("KeyButton", [
            __traits(allMembers, InputEvent.KeyButton.Button)
        ], cast(GrInt[])[EnumMembers!(InputEvent.KeyButton.Button)]);

    GrType mouseButton = library.addEnum("MouseButton", [
            __traits(allMembers, InputEvent.MouseButton.Button)
        ], cast(GrInt[])[EnumMembers!(InputEvent.MouseButton.Button)]);

    GrType controllerButton = library.addEnum("ControllerButton", [
            __traits(allMembers, InputEvent.ControllerButton.Button)
        ], cast(GrInt[])[EnumMembers!(InputEvent.ControllerButton.Button)]);

    GrType controllerAxis = library.addEnum("ControllerAxis", [
            __traits(allMembers, InputEvent.ControllerAxis.Axis)
        ], cast(GrInt[])[EnumMembers!(InputEvent.ControllerAxis.Axis)]);

    GrType inputEventType = library.addEnum("InputEventType",
        [__traits(allMembers, InputEvent.Type)]);

    GrType inputEvent = library.addNative("InputEvent");
    GrType inputEventKeyButton = library.addNative("InputEventKeyButton");
    GrType inputEventMouseButton = library.addNative("InputEventMouseButton");
    GrType inputEventMouseMotion = library.addNative("InputEventMouseMotion");
    GrType inputEventMouseWheel = library.addNative("InputEventMouseWheel");
    GrType inputEventControllerButton = library.addNative("InputEventControllerButton");
    GrType inputEventControllerAxis = library.addNative("InputEventControllerAxis");
    GrType inputEventTextInput = library.addNative("InputEventTextInput");
    GrType inputEventDropFile = library.addNative("InputEventDropFile");

    // InputEvent
    library.addCast(&_asString, inputEvent, grString);
    library.addProperty(&_type, null, "type", inputEvent, inputEventType);
    library.addFunction(&_inputEvent_isPressed, "isPressed", [inputEvent], [
            grBool
        ]);
    library.addFunction(&_inputEvent_echo, "echo", [inputEvent], [grBool]);

    library.addProperty(&_keyButton, null, "keyButton", inputEvent,
        grOptional(inputEventKeyButton));
    library.addProperty(&_mouseButton, null, "mouseButton", inputEvent,
        grOptional(inputEventMouseButton));
    library.addProperty(&_mouseMotion, null, "mouseMotion", inputEvent,
        grOptional(inputEventMouseMotion));
    library.addProperty(&_mouseWheel, null, "mouseWheel", inputEvent,
        grOptional(inputEventMouseWheel));
    library.addProperty(&_controllerButton, null, "controllerButton",
        inputEvent, grOptional(inputEventControllerButton));
    library.addProperty(&_controllerAxis, null, "controllerAxis", inputEvent,
        grOptional(inputEventControllerAxis));
    library.addProperty(&_textInput, null, "textInput", inputEvent,
        grOptional(inputEventTextInput));
    library.addProperty(&_dropFile, null, "dropFile", inputEvent, grOptional(inputEventDropFile));

    library.addFunction(&_accept, "accept", [inputEvent]);
    library.addFunction(&_print, "print", [inputEvent]);

    // KeyButton
    library.addProperty(&_KeyButton_button, null, "button", inputEventKeyButton, keyButton);
    library.addProperty(&_KeyButton_state, null, "state", inputEventKeyButton, keyState);
    library.addProperty(&_KeyButton_echo, null, "echo", inputEventKeyButton, grBool);

    // MouseButton
    library.addProperty(&_MouseButton_button, null, "button", inputEventMouseButton, keyButton);
    library.addProperty(&_MouseButton_state, null, "state", inputEventMouseButton, keyState);
    library.addProperty(&_MouseButton_clicks, null, "clicks", inputEventMouseButton, grInt);
    library.addProperty(&_MouseButton_globalX, null, "globalX", inputEventMouseButton, grInt);
    library.addProperty(&_MouseButton_globalY, null, "globalY", inputEventMouseButton, grInt);
    library.addProperty(&_MouseButton_relativeX, null, "relativeX", inputEventMouseButton, grInt);
    library.addProperty(&_MouseButton_relativeY, null, "relativeY", inputEventMouseButton, grInt);

    // MouseMotion
    library.addProperty(&_MouseMotion_globalX, null, "globalX", inputEventMouseMotion, grInt);
    library.addProperty(&_MouseMotion_globalY, null, "globalY", inputEventMouseMotion, grInt);
    library.addProperty(&_MouseMotion_relativeX, null, "relativeX", inputEventMouseMotion, grInt);
    library.addProperty(&_MouseMotion_relativeY, null, "relativeY", inputEventMouseMotion, grInt);

    // MouseWheel
    library.addProperty(&_MouseWheel_x, null, "x", inputEventMouseWheel, grInt);
    library.addProperty(&_MouseWheel_y, null, "y", inputEventMouseWheel, grInt);

    // ControllerButton
    library.addProperty(&_ControllerButton_button, null, "button",
        inputEventControllerButton, controllerButton);
    library.addProperty(&_ControllerButton_state, null, "state",
        inputEventControllerButton, keyState);

    // ControllerAxis
    library.addProperty(&_ControllerAxis_axis, null, "axis",
        inputEventControllerAxis, controllerButton);
    library.addProperty(&_ControllerAxis_value, null, "value", inputEventControllerAxis, grFloat);

    // TextInput
    library.addProperty(&_TextInput_text, null, "text", inputEventTextInput, grString);

    // DropFile
    library.addProperty(&_DropFile_path, null, "path", inputEventDropFile, grString);

    // Input

    library.addStatic(&_makeKeyButton1, inputEvent, "keyButton", [
            keyButton, keyState
        ], [inputEvent]);

    library.addStatic(&_makeKeyButton2, inputEvent, "keyButton", [
            keyButton, keyState, grBool
        ], [inputEvent]);

    library.addStatic(&_makeMouseButton, inputEvent, "mouseButton",
        [mouseButton, keyState, grInt, grInt, grInt, grInt, grInt], [inputEvent]);

    library.addStatic(&_makeMouseMotion, inputEvent, "mouseMotion", [
            grInt, grInt, grInt, grInt
        ], [inputEvent]);

    library.addStatic(&_makeMouseWheel, inputEvent, "mouseWheel", [grInt, grInt], [
            inputEvent
        ]);

    library.addStatic(&_makeControllerButton, inputEvent, "controllerButton",
        [controllerButton, keyState], [inputEvent]);

    library.addStatic(&_makeControllerAxis, inputEvent, "controllerAxis",
        [controllerAxis, grFloat], [inputEvent]);

    library.addStatic(&_makeTextInput, inputEvent, "textInput", [grString], [
            inputEvent
        ]);

    library.addStatic(&_makeDropFile, inputEvent, "dropFile", [grString], [
            inputEvent
        ]);

    library.addFunction(&_isPressed!(InputEvent.KeyButton.Button),
        "isPressed", [keyButton], [grBool]);
    library.addFunction(&_isPressed!(InputEvent.MouseButton.Button),
        "isPressed", [mouseButton], [grBool]);
    library.addFunction(&_isPressed!(InputEvent.ControllerButton.Button),
        "isPressed", [controllerButton], [grBool]);

    // Action

    library.addFunction(&_addAction, "addAction", [grString]);
    library.addFunction(&_removeAction, "removeAction", [grString]);
    library.addFunction(&_hasAction, "hasAction", [grString], [grBool]);
    library.addFunction(&_isAction, "isAction", [inputEvent, grString], [grBool]);
    library.addFunction(&_addActionEvent, "addActionEvent", [
            grString, inputEvent
        ]);
    library.addFunction(&_removeActionEvents, "removeActionEvents", [grString]);
    library.addFunction(&_isActionActivated, "isActionActivated", [grString], [
            grBool
        ]);
    library.addFunction(&_getActionStrength, "getActionStrength", [grString], [
            grFloat
        ]);
    library.addFunction(&_getActionAxis, "getActionAxis", [grString, grString], [
            grFloat
        ]);

}

private void _asString(GrCall call) {
    call.setString(call.getNative!InputEvent(0).prettify());
}

private void _type(GrCall call) {
    call.setEnum(call.getNative!InputEvent(0).type);
}

private void _inputEvent_isPressed(GrCall call) {
    call.setBool(call.getNative!InputEvent(0).pressed);
}

private void _inputEvent_echo(GrCall call) {
    call.setBool(call.getNative!InputEvent(0).echo);
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

private void _controllerButton(GrCall call) {
    InputEvent.ControllerButton controllerButton = call.getNative!InputEvent(0).asControllerButton;
    if (controllerButton)
        call.setNative(controllerButton);
    else
        call.setNull();
}

private void _controllerAxis(GrCall call) {
    InputEvent.ControllerAxis controllerAxis = call.getNative!InputEvent(0).asControllerAxis;
    if (controllerAxis)
        call.setNative(controllerAxis);
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

private void _KeyButton_state(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.KeyButton)(0).state);
}

private void _KeyButton_echo(GrCall call) {
    call.setBool(call.getNative!(InputEvent.KeyButton)(0).echo);
}

// MouseButton

private void _MouseButton_button(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.MouseButton)(0).button);
}

private void _MouseButton_state(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.MouseButton)(0).state);
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

private void _MouseButton_relativeX(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseButton)(0).relativePosition.x);
}

private void _MouseButton_relativeY(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseButton)(0).relativePosition.y);
}

// MouseMotion

private void _MouseMotion_globalX(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseMotion)(0).globalPosition.x);
}

private void _MouseMotion_globalY(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseMotion)(0).globalPosition.y);
}

private void _MouseMotion_relativeX(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseMotion)(0).relativePosition.x);
}

private void _MouseMotion_relativeY(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseMotion)(0).relativePosition.y);
}

// MouseWheel

private void _MouseWheel_x(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseWheel)(0).wheel.x);
}

private void _MouseWheel_y(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseWheel)(0).wheel.y);
}

// ControllerButton

private void _ControllerButton_button(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.ControllerButton)(0).button);
}

private void _ControllerButton_state(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.ControllerButton)(0).state);
}

// ControllerButton

private void _ControllerAxis_axis(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.ControllerAxis)(0).axis);
}

private void _ControllerAxis_value(GrCall call) {
    call.setFloat(call.getNative!(InputEvent.ControllerAxis)(0).value);
}

// TextInput

private void _TextInput_text(GrCall call) {
    call.setString(call.getNative!(InputEvent.TextInput)(0).text);
}

// DropFile

private void _DropFile_path(GrCall call) {
    call.setString(call.getNative!(InputEvent.DropFile)(0).path);
}

// Input

private void _makeKeyButton1(GrCall call) {
    call.setNative(InputEvent.keyButton(call.getEnum!(InputEvent.KeyButton.Button)(0),
                   InputState(call.getEnum!KeyState(1))));
}

private void _makeKeyButton2(GrCall call) {
    call.setNative(InputEvent.keyButton(call.getEnum!(InputEvent.KeyButton.Button)(0),
                   InputState(call.getEnum!KeyState(1)), call.getBool(2)));
}

private void _makeMouseButton(GrCall call) {
    call.setNative(InputEvent.mouseButton(call.getEnum!(InputEvent.MouseButton.Button)(0),
            InputState(call.getEnum!KeyState(1)), call.getInt(2), vec2i(call.getInt(3),
            call.getInt(4)), vec2i(call.getInt(5), call.getInt(6))));
}

private void _makeMouseMotion(GrCall call) {
    call.setNative(InputEvent.mouseMotion(vec2i(call.getInt(0),
            call.getInt(1)), vec2i(call.getInt(2), call.getInt(3))));
}

private void _makeMouseWheel(GrCall call) {
    call.setNative(InputEvent.mouseWheel(vec2i(call.getInt(0), call.getInt(1))));
}

private void _makeControllerButton(GrCall call) {
    call.setNative(InputEvent.controllerButton(
            call.getEnum!(InputEvent.ControllerButton.Button)(0), InputState(call.getEnum!KeyState(1))));
}

private void _makeControllerAxis(GrCall call) {
    call.setNative(InputEvent.controllerAxis(
            call.getEnum!(InputEvent.ControllerAxis.Axis)(0), call.getFloat(1)));
}

private void _makeTextInput(GrCall call) {
    call.setNative(InputEvent.textInput(call.getString(0)));
}

private void _makeDropFile(GrCall call) {
    call.setNative(InputEvent.dropFile(call.getString(0)));
}

private void _isPressed(T)(GrCall call) {
    call.setBool(application.inputManager.isPressed(call.getEnum!T(0)));
}

private void _getAxis(GrCall call) {
    call.setFloat(application.inputManager.getAxis(call.getEnum!(InputEvent.ControllerAxis.Axis)(0)));
}

// Action

private void _addAction(GrCall call) {
    application.inputManager.addAction(call.getString(0));
}

private void _removeAction(GrCall call) {
    application.inputManager.removeAction(call.getString(0));
}

private void _hasAction(GrCall call) {
    call.setBool(application.inputManager.hasAction(call.getString(0)));
}

private void _isAction(GrCall call) {
    call.setBool(application.inputManager.isAction(call.getString(1), call.getNative!InputEvent(0)));
}

private void _addActionEvent(GrCall call) {
    application.inputManager.addActionEvent(call.getString(0), call.getNative!InputEvent(1));
}

private void _removeActionEvents(GrCall call) {
    application.inputManager.removeActionEvents(call.getString(0));
}

private void _isActionActivated(GrCall call) {
    call.setBool(application.inputManager.activated(call.getString(0)));
}

private void _getActionStrength(GrCall call) {
    call.setFloat(application.inputManager.getActionStrength(call.getString(0)));
}

private void _getActionAxis(GrCall call) {
    call.setFloat(application.inputManager.getActionAxis(call.getString(0), call.getString(1)));
}
