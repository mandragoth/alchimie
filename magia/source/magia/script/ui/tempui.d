module magia.script.ui.tempui;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;
import magia.core;
import magia.kernel;
import magia.ui;

package void loadLibUI_tempui(GrModule library) {
    GrType splineType = grGetEnumType("Spline");
    GrType alignXType = library.addEnum("AlignX", ["left", "center", "right"]);
    GrType alignYType = library.addEnum("AlignY", ["top", "center", "bottom"]);
    GrType stateType = library.addNative("UIState");

    GrType uiType = library.addNative("UI", [], "Entity");
    GrType labelType = library.addNative("Label", [], "UI");

    // Commun aux UI
    library.addFunction(&_ui_size, "size", [uiType, grFloat, grFloat]);
    library.addProperty(&_ui_sizeX!"get", &_ui_sizeX!"set", "sizeX", uiType, grFloat);
    library.addProperty(&_ui_sizeY!"get", &_ui_sizeY!"set", "sizeY", uiType, grFloat);

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

    library.addFunction(&_ui_state_offset, "offset", [
            stateType, grFloat, grFloat
        ]);
    library.addProperty(&_ui_state_offsetX!"get", &_ui_state_offsetX!"set",
        "offsetX", stateType, grFloat);
    library.addProperty(&_ui_state_offsetY!"get", &_ui_state_offsetY!"set",
        "offsetY", stateType, grFloat);

    library.addProperty(&_ui_state_angle!"get", &_ui_state_angle!"set",
        "angle", stateType, grFloat);
    library.addProperty(&_ui_state_alpha!"get", &_ui_state_alpha!"set",
        "alpha", stateType, grFloat);

    library.addProperty(&_ui_state_ticks!"get", &_ui_state_ticks!"set",
        "ticks", stateType, grUInt);
    library.addProperty(&_ui_state_spline!"get", &_ui_state_spline!"set",
        "spline", stateType, splineType);

    library.addFunction(&_ui_addState, "addState", [uiType, stateType]);
    library.addFunction(&_ui_setState, "setState", [uiType, grString]);
    library.addFunction(&_ui_runState, "runState", [uiType, grString]);

    library.addFunction(&_ui_append_root, "appendUI", [uiType]);
    library.addFunction(&_ui_append_child, "append", [uiType, uiType]);

    // Labels
    library.addConstructor(&_label_new, labelType, [grString]);
    library.addFunction(&_label_text, "text", [labelType, grString]);
}

private void _ui_size(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.size.x = call.getFloat(1);
    ui.size.y = call.getFloat(2);
}

private void _ui_sizeX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.size.x = call.getFloat(1);
    }
    call.setFloat(ui.size.x);
}

private void _ui_sizeY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.size.y = call.getFloat(1);
    }
    call.setFloat(ui.size.y);
}

private void _ui_pivot(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    ui.pivot.x = call.getFloat(1);
    ui.pivot.y = call.getFloat(2);
}

private void _ui_pivotX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.pivot.x = call.getFloat(1);
    }
    call.setFloat(ui.pivot.x);
}

private void _ui_pivotY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.pivot.y = call.getFloat(1);
    }
    call.setFloat(ui.pivot.y);
}

private void _ui_angle(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        ui.transform.rotation.angle = call.getFloat(1);
    }
    call.setFloat(ui.transform.rotation.angle);
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

    state.offset.x = call.getFloat(1);
    state.offset.y = call.getFloat(2);
}

private void _ui_state_offsetX(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.offset.x = call.getFloat(1);
    }
    call.setFloat(state.offset.x);
}

private void _ui_state_offsetY(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.offset.y = call.getFloat(1);
    }
    call.setFloat(state.offset.y);
}

private void _ui_state_scale(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }

    state.transform.scale.x = call.getFloat(1);
    state.transform.scale.y = call.getFloat(2);
}

private void _ui_state_scaleX(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.transform.scale.x = call.getFloat(1);
    }
    call.setFloat(state.transform.scale.x);
}

private void _ui_state_scaleY(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.transform.scale.y = call.getFloat(1);
    }
    call.setFloat(state.transform.scale.y);
}

private void _ui_state_angle(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.transform.rotation.angle = call.getFloat(1);
    }
    call.setFloat(state.transform.rotation.angle);
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

private void _ui_state_ticks(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);
    if (!state) {
        call.raise("NullError");
        return;
    }
    static if (op == "set") {
        state.ticks = call.getUInt(1);
    }
    call.setUInt(state.ticks);
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
    ui.transform = ptr.transform;
    ui.offset.x = ptr.offset.x;
    ui.offset.y = ptr.offset.y;
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
    ui.initState.transform = ui.transform;
    ui.initState.offset.x = ui.offset.x;
    ui.initState.offset.y = ui.offset.y;
    ui.initState.alpha = ui.alpha;
    ui.initState.ticks = ui.timer.duration;
    ui.targetState = *ptr;
    ui.timer.start(ptr.ticks);
}

private void _ui_append_root(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    if (!ui) {
        call.raise("NullError");
        return;
    }

    Magia.ui.appendRoot(ui);
}

private void _ui_append_child(GrCall call) {
    UIElement uiParent = call.getNative!UIElement(0);
    UIElement uiChild = call.getNative!UIElement(1);
    if (!uiParent || !uiChild) {
        call.raise("NullError");
        return;
    }

    uiParent.children ~= uiChild;
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