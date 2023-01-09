module magia.input.inputmap;

import std.algorithm.mutation : remove;

import magia.input.inputevent;

/// Associe une action à un événement
final class InputAction {
    /// Nom de l’action
    string name;

    /// Événements activant l’action
    InputEvent[] events;

    /// Seuil d’activation de l’action
    float deadzone;
}

/// Gère l’association de certaines entrés avec leurs actions correspondantes
final class InputMap {
    private {
        InputAction[string] _inputActions;
    }

    @property {

    }

    /// Init
    this() {

    }

    /// Ajoute une nouvelle action
    void addAction(string action, float deadzone) {
        InputAction inputAction = new InputAction;
        inputAction.name = action;
        inputAction.deadzone = deadzone;
        _inputActions[action] = inputAction;
    }

    /// Retire une action existante
    void removeAction(string action) {
        _inputActions.remove(action);
    }

    /// Vérifie si une action existe
    bool hasAction(string action) const {
        auto p = action in _inputActions;
        return p !is null;
    }

    /// Associe un événement à une action existante
    void addActionEvent(string action, InputEvent event) {
        auto p = action in _inputActions;

        if (!p) {
            return;
        }

        (*p).events ~= event;
    }

    /// Supprime un événement associé à une action
    void removeActionEvents(string action, InputEvent event) {
        auto p = action in _inputActions;

        if (!p) {
            return;
        }

        for (size_t i; i < (*p).events.length; ++i) {
            if ((*p).events[i] == event) {
                (*p).events = (*p).events.remove(i);
                break;
            }
        }
    }

    /// Supprime tous les événements associés à une action
    void removeActionEvents(string action) {
        auto p = action in _inputActions;

        if (!p) {
            return;
        }

        (*p).events.length = 0;
    }

    string[] getActions() {
        return _inputActions.keys;
    }
}
