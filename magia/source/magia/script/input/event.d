module magia.script.input.event;

import std.traits;

import grimoire;
import magia.core;
import magia.input;
import magia.kernel;
import magia.script.common;

void loadLibInput_event(GrModule mod) {
    mod.setModule("input.event");
    mod.setModuleInfo(GrLocale.fr_FR, "Événements d’entrée");

    GrType vec2fType = grGetNativeType("vec2", [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "État d’une entrée");
    GrType keyState = mod.addEnum("KeyState", grNativeEnum!(KeyState));

    mod.setDescription(GrLocale.fr_FR, "Touche du clavier");
    GrType keyButton = mod.addEnum("KeyButton", grNativeEnum!(InputEvent.KeyButton.Button));

    mod.setDescription(GrLocale.fr_FR, "Bouton de la souris");
    GrType mouseButton = mod.addEnum("MouseButton", grNativeEnum!(InputEvent.MouseButton.Button));

    mod.setDescription(GrLocale.fr_FR, "Bouton de la manette");
    GrType controllerButton = mod.addEnum("ControllerButton",
        grNativeEnum!(InputEvent.ControllerButton.Button));

    mod.setDescription(GrLocale.fr_FR, "Axe de la manette");
    GrType controllerAxis = mod.addEnum("ControllerAxis",
        grNativeEnum!(InputEvent.ControllerAxis.Axis));

    mod.setDescription(GrLocale.fr_FR, "Type d’événement");
    GrType inputEventType = mod.addEnum("InputEventType", grNativeEnum!(InputEvent.Type));

    GrType inputEvent = mod.addNative("InputEvent");
    GrType inputEventKeyButton = mod.addNative("InputEventKeyButton");
    GrType inputEventMouseButton = mod.addNative("InputEventMouseButton");
    GrType inputEventMouseMotion = mod.addNative("InputEventMouseMotion");
    GrType inputEventMouseWheel = mod.addNative("InputEventMouseWheel");
    GrType inputEventControllerButton = mod.addNative("InputEventControllerButton");
    GrType inputEventControllerAxis = mod.addNative("InputEventControllerAxis");
    GrType inputEventTextInput = mod.addNative("InputEventTextInput");
    GrType inputEventDropFile = mod.addNative("InputEventDropFile");

    // InputEvent
    mod.addCast(&_asString, inputEvent, grString);
    mod.addProperty(&_type, null, "type", inputEvent, inputEventType);

    mod.setDescription(GrLocale.fr_FR, "L’événement correspond-il à l’action ?");
    mod.setParameters(["event", "action"]);
    mod.addFunction(&_isAction, "isAction", [inputEvent, grString], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "La touche est-elle active ?");
    mod.addFunction(&_inputEvent_isPressed, "isPressed", [inputEvent], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "L’événement est-il déclenché par répétition ?");
    mod.addFunction(&_inputEvent_echo, "echo", [inputEvent], [grBool]);

    mod.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventKeyButton, retourne le type.");
    mod.addProperty(&_keyButton, null, "keyButton", inputEvent, grOptional(inputEventKeyButton));

    mod.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventMouseButton, retourne le type.");
    mod.addProperty(&_mouseButton, null, "mouseButton", inputEvent,
        grOptional(inputEventMouseButton));

    mod.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventMouseMotion, retourne le type.");
    mod.addProperty(&_mouseMotion, null, "mouseMotion", inputEvent,
        grOptional(inputEventMouseMotion));

    mod.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventMouseWheel, retourne le type.");
    mod.addProperty(&_mouseWheel, null, "mouseWheel", inputEvent,
        grOptional(inputEventMouseWheel));

    mod.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventControllerButton, retourne le type.");
    mod.addProperty(&_controllerButton, null, "controllerButton", inputEvent,
        grOptional(inputEventControllerButton));

    mod.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventControllerAxis, retourne le type.");
    mod.addProperty(&_controllerAxis, null, "controllerAxis", inputEvent,
        grOptional(inputEventControllerAxis));

    mod.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventTextInput, retourne le type.");
    mod.addProperty(&_textInput, null, "textInput", inputEvent, grOptional(inputEventTextInput));

    mod.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventDropFile, retourne le type.");
    mod.addProperty(&_dropFile, null, "dropFile", inputEvent, grOptional(inputEventDropFile));

    mod.setDescription(GrLocale.fr_FR, "Consomme l’événement.");
    mod.addFunction(&_accept, "accept", [inputEvent]);

    mod.setDescription(GrLocale.fr_FR, "Affiche le contenu de l’événement.");
    mod.addFunction(&_print, "print", [inputEvent]);

    // KeyButton
    mod.addProperty(&_KeyButton_button, null, "button", inputEventKeyButton, keyButton);
    mod.addProperty(&_KeyButton_state, null, "state", inputEventKeyButton, keyState);
    mod.addProperty(&_KeyButton_echo, null, "echo", inputEventKeyButton, grBool);

    // MouseButton
    mod.addProperty(&_MouseButton_button, null, "button", inputEventMouseButton, keyButton);
    mod.addProperty(&_MouseButton_state, null, "state", inputEventMouseButton, keyState);
    mod.addProperty(&_MouseButton_clicks, null, "clicks", inputEventMouseButton, grInt);
    mod.addProperty(&_MouseButton_position, null, "position", inputEventMouseButton, vec2fType);
    mod.addProperty(&_MouseButton_deltaPosition, null, "deltaPosition",
        inputEventMouseButton, vec2fType);

    // MouseMotion
    mod.addProperty(&_MouseMotion_position, null, "position", inputEventMouseMotion, vec2fType);
    mod.addProperty(&_MouseMotion_deltaPosition, null, "deltaPosition",
        inputEventMouseMotion, vec2fType);

    // MouseWheel
    mod.addProperty(&_MouseWheel_x, null, "x", inputEventMouseWheel, grInt);
    mod.addProperty(&_MouseWheel_y, null, "y", inputEventMouseWheel, grInt);

    // ControllerButton
    mod.addProperty(&_ControllerButton_button, null, "button",
        inputEventControllerButton, controllerButton);
    mod.addProperty(&_ControllerButton_state, null, "state", inputEventControllerButton, keyState);

    // ControllerAxis
    mod.addProperty(&_ControllerAxis_axis, null, "axis",
        inputEventControllerAxis, controllerButton);
    mod.addProperty(&_ControllerAxis_value, null, "value", inputEventControllerAxis, grFloat);

    // TextInput
    mod.addProperty(&_TextInput_text, null, "text", inputEventTextInput, grString);

    // DropFile
    mod.addProperty(&_DropFile_path, null, "path", inputEventDropFile, grString);

    // Input

    mod.setDescription(GrLocale.fr_FR, "Crée un événement clavier.");
    mod.addStatic(&_makeKeyButton1, inputEvent, "keyButton", [
            keyButton, keyState
        ], [inputEvent]);

    mod.addStatic(&_makeKeyButton2, inputEvent, "keyButton", [
            keyButton, keyState, grBool
        ], [inputEvent]);

    mod.setDescription(GrLocale.fr_FR, "Crée un événement bouton de souris.");
    mod.addStatic(&_makeMouseButton, inputEvent, "mouseButton", [
            mouseButton, keyState, grInt, vec2fType, vec2fType
        ], [inputEvent]);

    mod.setDescription(GrLocale.fr_FR, "Crée un événement déplacement de souris.");
    mod.addStatic(&_makeMouseMotion, inputEvent, "mouseMotion", [
            vec2fType, vec2fType
        ], [inputEvent]);

    mod.setDescription(GrLocale.fr_FR, "Crée un événement molette de souris.");
    mod.addStatic(&_makeMouseWheel, inputEvent, "mouseWheel", [grInt, grInt], [
            inputEvent
        ]);

    mod.setDescription(GrLocale.fr_FR, "Crée un événement bouton de manette.");
    mod.addStatic(&_makeControllerButton, inputEvent, "controllerButton",
        [controllerButton, keyState], [inputEvent]);

    mod.setDescription(GrLocale.fr_FR, "Crée un événement axe de manette.");
    mod.addStatic(&_makeControllerAxis, inputEvent, "controllerAxis",
        [controllerAxis, grFloat], [inputEvent]);

    mod.setDescription(GrLocale.fr_FR, "Crée un événement entrée textuelle.");
    mod.addStatic(&_makeTextInput, inputEvent, "textInput", [grString], [
            inputEvent
        ]);

    mod.setDescription(GrLocale.fr_FR, "Crée un événement fichier déposé.");
    mod.addStatic(&_makeDropFile, inputEvent, "dropFile", [grString], [
            inputEvent
        ]);
}

private void _asString(GrCall call) {
    call.setString(call.getNative!InputEvent(0).prettify());
}

private void _type(GrCall call) {
    call.setEnum(call.getNative!InputEvent(0).type);
}

private void _isAction(GrCall call) {
    call.setBool(Magia.input.isAction(call.getString(1), call.getNative!InputEvent(0)));
}

private void _inputEvent_isPressed(GrCall call) {
    call.setBool(call.getNative!InputEvent(0).isPressed());
}

private void _inputEvent_echo(GrCall call) {
    call.setBool(call.getNative!InputEvent(0).isEcho());
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
    call.task.engine.print(call.getNative!InputEvent(0).prettify());
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

private void _MouseButton_position(GrCall call) {
    call.setNative(svec2(call.getNative!(InputEvent.MouseButton)(0).position));
}

private void _MouseButton_deltaPosition(GrCall call) {
    call.setNative(svec2(call.getNative!(InputEvent.MouseButton)(0).deltaPosition));
}

// MouseMotion

private void _MouseMotion_position(GrCall call) {
    call.setNative(svec2(call.getNative!(InputEvent.MouseMotion)(0).position));
}

private void _MouseMotion_deltaPosition(GrCall call) {
    call.setNative(svec2(call.getNative!(InputEvent.MouseMotion)(0).deltaPosition));
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
            InputState(call.getEnum!KeyState(1)), call.getInt(2),
            call.getNative!SVec2f(3), call.getNative!SVec2f(4)));
}

private void _makeMouseMotion(GrCall call) {
    call.setNative(InputEvent.mouseMotion(call.getNative!SVec2f(0), call.getNative!SVec2f(1)));
}

private void _makeMouseWheel(GrCall call) {
    call.setNative(InputEvent.mouseWheel(vec2i(call.getInt(0), call.getInt(1))));
}

private void _makeControllerButton(GrCall call) {
    call.setNative(InputEvent.controllerButton(call.getEnum!(InputEvent.ControllerButton.Button)(0),
            InputState(call.getEnum!KeyState(1))));
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
