module magia.script.input.input;

import std.traits;

import grimoire;
import magia.core;
import magia.input;
import magia.kernel;
import magia.script.common;

void loadLibInput_input(GrModule mod) {
    mod.setModule("input.input");
    mod.setModuleInfo(GrLocale.fr_FR, "Entrées utilisateur");

    GrType vec2fType = grGetNativeType("vec2", [grFloat]);

    GrType keyButton = grGetEnumType("KeyButton");
    GrType mouseButton = grGetEnumType("MouseButton");
    GrType controllerButton = grGetEnumType("ControllerButton");
    GrType controllerAxis = grGetEnumType("ControllerAxis");

    GrType inputType = mod.addNative("Input");

    GrType inputEvent = grGetNativeType("InputEvent");

    mod.setDescription(GrLocale.fr_FR, "La touche est-elle appuyée sur cette frame ?");
    mod.setParameters(["input"]);
    mod.addStatic(&_isDown!(InputEvent.KeyButton.Button), inputType,
        "isDown", [keyButton], [grBool]);
    mod.addStatic(&_isDown!(InputEvent.MouseButton.Button), inputType,
        "isDown", [mouseButton], [grBool]);
    mod.addStatic(&_isDown!(InputEvent.ControllerButton.Button), inputType,
        "isDown", [controllerButton], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "La touche est-elle relâchée sur cette frame ?");
    mod.setParameters(["input"]);
    mod.addStatic(&_isUp!(InputEvent.KeyButton.Button), inputType, "isUp", [
            keyButton
        ], [grBool]);
    mod.addStatic(&_isUp!(InputEvent.MouseButton.Button), inputType, "isUp",
        [mouseButton], [grBool]);
    mod.addStatic(&_isUp!(InputEvent.ControllerButton.Button), inputType,
        "isUp", [controllerButton], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "La touche est-elle enfoncée ?");
    mod.setParameters(["input"]);
    mod.addStatic(&_isHeld!(InputEvent.KeyButton.Button), inputType,
        "isHeld", [keyButton], [grBool]);
    mod.addStatic(&_isHeld!(InputEvent.MouseButton.Button), inputType,
        "isHeld", [mouseButton], [grBool]);
    mod.addStatic(&_isHeld!(InputEvent.ControllerButton.Button), inputType,
        "isHeld", [controllerButton], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "La touche est-elle pressée ?");
    mod.setParameters(["input"]);
    mod.addStatic(&_isPressed!(InputEvent.KeyButton.Button), inputType,
        "isPressed", [keyButton], [grBool]);
    mod.addStatic(&_isPressed!(InputEvent.MouseButton.Button), inputType,
        "isPressed", [mouseButton], [grBool]);
    mod.addStatic(&_isPressed!(InputEvent.ControllerButton.Button),
        inputType, "isPressed", [controllerButton], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "Position du curseur");
    mod.setParameters();
    mod.addStatic(&_getMousePosition, inputType, "getMousePosition", [], [
            vec2fType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Position relative du curseur");
    mod.setParameters();
    mod.addStatic(&_getDeltaMousePosition, inputType, "getDeltaMousePosition", [
        ], [vec2fType]);

    mod.setDescription(GrLocale.fr_FR, "Valeur de l’axe de la manette");
    mod.setParameters(["axis"]);
    mod.addStatic(&_getAxis, inputType, "getAxis", [controllerAxis], [grFloat]);

    // Action

    mod.setDescription(GrLocale.fr_FR, "Défini une nouvelle action");
    mod.setParameters(["action"]);
    mod.addStatic(&_addAction, inputType, "addAction", [grString]);

    mod.setDescription(GrLocale.fr_FR, "Supprime une action existante");
    mod.setParameters(["action"]);
    mod.addStatic(&_removeAction, inputType, "removeAction", [grString]);

    mod.setDescription(GrLocale.fr_FR, "Vérifie si l’action existe");
    mod.setParameters(["action"]);
    mod.addStatic(&_hasAction, inputType, "hasAction", [grString], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "L’événement correspond-il a l’action ?");
    mod.setParameters(["action", "event"]);
    mod.addStatic(&_isAction, inputType, "isAction", [grString, inputEvent], [
            grBool
        ]);

    mod.setDescription(GrLocale.fr_FR, "Associe un événement à une action");
    mod.setParameters(["action", "event"]);
    mod.addStatic(&_addActionEvent, inputType, "addActionEvent", [
            grString, inputEvent
        ]);

    mod.setDescription(GrLocale.fr_FR, "Supprime les événements associés à une action");
    mod.setParameters(["action"]);
    mod.addStatic(&_removeActionEvents, inputType, "removeActionEvents", [
            grString
        ]);

    mod.setDescription(GrLocale.fr_FR, "L’action a-t’elle été déclenchée ?");
    mod.setParameters(["action"]);
    mod.addStatic(&_isActionActivated, inputType, "isActionActivated", [
            grString
        ], [grBool]);

    mod.setDescription(GrLocale.fr_FR, "Récupère l’intensité de l’action");
    mod.setParameters(["action"]);
    mod.addStatic(&_getActionStrength, inputType, "getActionStrength", [
            grString
        ], [grFloat]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère l’intensité sous forme d’un axe défini par 2 actions (l’un positif, l’autre négatif)");
    mod.setParameters(["negative", "positive"]);
    mod.addStatic(&_getActionAxis, inputType, "getActionAxis", [
            grString, grString
        ], [grFloat]);

    mod.setDescription(GrLocale.fr_FR,
        "Récupère l’intensité sous forme d’un vecteur défini par 4 actions");
    mod.setParameters(["left", "right", "up", "down"]);
    mod.addStatic(&_getActionVector, inputType, "getActionVector", [
            grString, grString, grString, grString
        ], [vec2fType]);
}

private void _isDown(T)(GrCall call) {
    call.setBool(Magia.input.isDown(call.getEnum!T(0)));
}

private void _isUp(T)(GrCall call) {
    call.setBool(Magia.input.isUp(call.getEnum!T(0)));
}

private void _isHeld(T)(GrCall call) {
    call.setBool(Magia.input.isHeld(call.getEnum!T(0)));
}

private void _isPressed(T)(GrCall call) {
    call.setBool(Magia.input.isPressed(call.getEnum!T(0)));
}

private void _getMousePosition(GrCall call) {
    call.setNative(svec2(Magia.input.mousePosition));
}

private void _getDeltaMousePosition(GrCall call) {
    call.setNative(svec2(Magia.input.deltaMousePosition));
}

private void _getAxis(GrCall call) {
    call.setFloat(Magia.input.getAxis(call.getEnum!(InputEvent.ControllerAxis.Axis)(0)));
}

// Action

private void _addAction(GrCall call) {
    Magia.input.addAction(call.getString(0));
}

private void _removeAction(GrCall call) {
    Magia.input.removeAction(call.getString(0));
}

private void _hasAction(GrCall call) {
    call.setBool(Magia.input.hasAction(call.getString(0)));
}

private void _isAction(GrCall call) {
    call.setBool(Magia.input.isAction(call.getString(0), call.getNative!InputEvent(1)));
}

private void _addActionEvent(GrCall call) {
    Magia.input.addActionEvent(call.getString(0), call.getNative!InputEvent(1));
}

private void _removeActionEvents(GrCall call) {
    Magia.input.removeActionEvents(call.getString(0));
}

private void _isActionActivated(GrCall call) {
    call.setBool(Magia.input.activated(call.getString(0)));
}

private void _getActionStrength(GrCall call) {
    call.setFloat(Magia.input.getActionStrength(call.getString(0)));
}

private void _getActionAxis(GrCall call) {
    call.setFloat(Magia.input.getActionAxis(call.getString(0), call.getString(1)));
}

private void _getActionVector(GrCall call) {
    call.setNative(svec2(Magia.input.getActionVector(call.getString(0),
            call.getString(1), call.getString(2), call.getString(3))));
}
