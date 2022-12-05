module sorcier.script.ui;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;
import magia.core;
import magia.ui;

package void loadMagiaLibUI(GrLibrary library) {
    GrType splineType = grGetEnumType("Spline");
    GrType alignXType = library.addEnum("AlignX", ["left", "center", "right"]);
    GrType alignYType = library.addEnum("AlignY", ["top", "center", "bottom"]);
    GrType stateType = library.addNative("UIState");

    GrType uiType = library.addNative("UI");
    GrType labelType = library.addNative("Label", [], "UI");

    // Commun aux UI
    library.addFunction(&_ui_pos, "pos", [uiType, grFloat, grFloat]);
    library.addProperty(&_ui_posX!"get", &_ui_posX!"set", "posX", uiType, grFloat);
    library.addProperty(&_ui_posY!"get", &_ui_posY!"set", "posY", uiType, grFloat);

    library.addFunction(&_ui_size, "size", [uiType, grFloat, grFloat]);
    library.addProperty(&_ui_sizeX!"get", &_ui_sizeX!"set", "sizeX", uiType, grFloat);
    library.addProperty(&_ui_sizeY!"get", &_ui_sizeY!"set", "sizeY", uiType, grFloat);

    library.addFunction(&_ui_scale, "scale", [uiType, grFloat, grFloat]);
    library.addProperty(&_ui_scaleX!"get", &_ui_scaleX!"set", "scaleX", uiType, grFloat);
    library.addProperty(&_ui_scaleY!"get", &_ui_scaleY!"set", "scaleY", uiType, grFloat);

    library.addFunction(&_ui_pivot, "pivot", [uiType, grFloat, grFloat]);
    library.addProperty(&_ui_pivotX!"get", &_ui_pivotX!"set", "pivotX", uiType, grFloat);
    library.addProperty(&_ui_pivotY!"get", &_ui_pivotY!"set", "pivotY", uiType, grFloat);

    library.addProperty(&_ui_angle!"get", &_ui_angle!"set", "angle", uiType, grFloat);

    library.addProperty(&_ui_alpha!"get", &_ui_alpha!"set", "alpha", uiType, grFloat);

    library.addFunction(&_ui_align, "align", [uiType, alignXType, alignYType]);
    library.addProperty(&_ui_alignX!"get", &_ui_alignX!"set", "alignX", uiType, alignXType);
    library.addProperty(&_ui_alignY!"get", &_ui_alignY!"set", "alignY", uiType, alignYType);

    library.addProperty(&_ui_isHovered, null, "hover?", uiType, grBool);
    library.addProperty(&_ui_isClicked, null, "click?", uiType, grBool);

    library.addConstructor(&_ui_state_new, stateType, [grString]);

    library.addFunction(&_ui_state_offset, "offset", [stateType, grFloat, grFloat]);
    library.addProperty(&_ui_state_offsetX!"get", &_ui_state_offsetX!"set", "offsetX", stateType, grFloat);
    library.addProperty(&_ui_state_offsetY!"get", &_ui_state_offsetY!"set", "offsetY", stateType, grFloat);

    library.addFunction(&_ui_state_scale, "scale", [stateType, grFloat, grFloat]);
    library.addProperty(&_ui_state_scaleX!"get", &_ui_state_scaleX!"set", "scaleX", stateType, grFloat);
    library.addProperty(&_ui_state_scaleY!"get", &_ui_state_scaleY!"set", "scaleY", stateType, grFloat);

    library.addProperty(&_ui_state_angle!"get", &_ui_state_angle!"set", "angle", stateType, grFloat);
    library.addProperty(&_ui_state_alpha!"get", &_ui_state_alpha!"set", "alpha", stateType, grFloat);

    library.addProperty(&_ui_state_time!"get", &_ui_state_time!"set", "time", stateType, grFloat);
    library.addProperty(&_ui_state_spline!"get", &_ui_state_spline!"set", "spline", stateType, splineType);

    library.addFunction(&_ui_addState, "addState", [uiType, stateType]);
    library.addFunction(&_ui_setState, "setState", [uiType, grString]);
    library.addFunction(&_ui_runState, "runState", [uiType, grString]);

    library.addFunction(&_ui_append_root, "appendUI", [uiType]);
    library.addFunction(&_ui_append_child, "append", [uiType, uiType]);

    // Labels
    library.addConstructor(&_label_new, labelType, [grString]);
    library.addFunction(&_label_text, "text", [labelType, grString]);
}

private void _ui_pos(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.posX = call.getFloat(1);
    ui.posY = call.getFloat(2);
}

private void _ui_posX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.posX = call.getFloat(1);
    }
    call.setFloat(ui.posX);
}

private void _ui_posY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.posY = call.getFloat(1);
    }
    call.setFloat(ui.posY);
}

private void _ui_size(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.sizeX = call.getFloat(1);
    ui.sizeY = call.getFloat(2);
}

private void _ui_sizeX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.sizeX = call.getFloat(1);
    }
    call.setFloat(ui.sizeX);
}

private void _ui_sizeY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.sizeY = call.getFloat(1);
    }
    call.setFloat(ui.sizeY);
}

private void _ui_scale(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.scaleX = call.getFloat(1);
    ui.scaleY = call.getFloat(2);
}

private void _ui_scaleX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.scaleX = call.getFloat(1);
    }
    call.setFloat(ui.scaleX);
}

private void _ui_scaleY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.scaleY = call.getFloat(1);
    }
    call.setFloat(ui.scaleY);
}

private void _ui_pivot(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.pivotX = call.getFloat(1);
    ui.pivotY = call.getFloat(2);
}

private void _ui_pivotX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.pivotX = call.getFloat(1);
    }
    call.setFloat(ui.pivotX);
}

private void _ui_pivotY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.pivotY = call.getFloat(1);
    }
    call.setFloat(ui.pivotY);
}

private void _ui_angle(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.angle = call.getFloat(1);
    }
    call.setFloat(ui.angle);
}

private void _ui_alpha(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.alpha = call.getFloat(1);
    }
    call.setFloat(ui.alpha);
}

private void _ui_align(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.alignX = call.getEnum!(UIElement.AlignX)(1);
    ui.alignY = call.getEnum!(UIElement.AlignY)(2);
}

private void _ui_alignX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.alignX = call.getEnum!(UIElement.AlignX)(1);
    }
    call.setEnum!(UIElement.AlignX)(ui.alignX);
}

private void _ui_alignY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.alignY = call.getEnum!(UIElement.AlignY)(1);
    }
    call.setEnum!(UIElement.AlignY)(ui.alignY);
}

private void _ui_isHovered(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    call.setBool(ui.isHovered);
}

private void _ui_isClicked(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    call.setBool(ui.isClicked);
}

private void _ui_state_new(GrCall call) {
    UIElement.State state = new UIElement.State;
    state.name = call.getString(0);
    call.setNative(state);
}

private void _ui_state_offset(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }

    state.offsetX = call.getFloat(1);
    state.offsetY = call.getFloat(2);
}

private void _ui_state_offsetX(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.offsetX = call.getFloat(1);
    }
    call.setFloat(state.offsetX);
}

private void _ui_state_offsetY(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.offsetY = call.getFloat(1);
    }
    call.setFloat(state.offsetY);
}

private void _ui_state_scale(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }

    state.scaleX = call.getFloat(1);
    state.scaleY = call.getFloat(2);
}

private void _ui_state_scaleX(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.scaleX = call.getFloat(1);
    }
    call.setFloat(state.scaleX);
}

private void _ui_state_scaleY(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.scaleY = call.getFloat(1);
    }
    call.setFloat(state.scaleY);
}

private void _ui_state_angle(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.angle = call.getFloat(1);
    }
    call.setFloat(state.angle);
}

private void _ui_state_alpha(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.alpha = call.getFloat(1);
    }
    call.setFloat(state.alpha);
}

private void _ui_state_time(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.time = call.getFloat(1);
    }
    call.setFloat(state.time);
}

private void _ui_state_spline(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.spline = call.getEnum!Spline(1);
    }
    call.setEnum!Spline(state.spline);
}

private void _ui_addState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    UIElement.State state = call.getNative!(UIElement.State)(1);
    if (!ui || !state) {
        call.raise("NullError");
        return;
    }

    ui.states[state.name] = state;
}

private void _ui_setState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    const auto ptr = call.getString(1) in ui.states;
    if (!ptr) {
        call.raise("NullError");
        return;
    }

    ui.currentStateName = ptr.name;
    ui.initState = null;
    ui.targetState = null;
    ui.offsetX = ptr.offsetX;
    ui.offsetY = ptr.offsetY;
    ui.scaleX = ptr.scaleX;
    ui.scaleX = ptr.scaleX;
    ui.angle = ptr.angle;
    ui.alpha = ptr.alpha;
    ui.timer.stop();
}

private void _ui_runState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    auto ptr = call.getString(1) in ui.states;
    if (!ptr) {
        call.raise("NullError");
        return;
    }

    ui.currentStateName = ptr.name;
    ui.initState = new UIElement.State;
    ui.initState.offsetX = ui.offsetX;
    ui.initState.offsetY = ui.offsetY;
    ui.initState.scaleX = ui.scaleX;
    ui.initState.scaleY = ui.scaleY;
    ui.initState.angle = ui.angle;
    ui.initState.alpha = ui.alpha;
    ui.initState.time = ui.timer.duration;
    ui.targetState = *ptr;
    ui.timer.start(ptr.time);
}

private void _ui_append_root(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    appendRoot(ui);
}

private void _ui_append_child(GrCall call) {
    UIElement uiParent = call.getNative!UIElement(0);
    UIElement uiChild = call.getNative!UIElement(1);
    if (!uiParent || !uiChild) {
        call.raise("NullError");
        return;
    }

    uiParent._children ~= uiChild;
}

private void _label_new(GrCall call) {
    Label label = new Label(call.getString(0));
    call.setNative(label);
}

private void _label_text(GrCall call) {
    Label label = call.getNative!Label(0);
    if (!label) {
        call.raise("NullError");
        return;
    }

    label.text = call.getString(1);
}
