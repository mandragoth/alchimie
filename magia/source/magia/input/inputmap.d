module magia.input.inputmap;

import std.algorithm.mutation : remove;

import magia.input.inputevent;

/// Associe une action à un événement
final class InputAction {
    /// Nom de l’action
    string id;

    /// Événements activant l’action
    InputEvent[] events;

    /// Seuil d’activation de l’action
    float deadzone;

    /// Init
    this(string id_, float deadzone_ = .2f) {
        id = id_;
        deadzone = deadzone_;
    }

    /// L’événement active-t’il cette action ?
    bool match(InputEvent event_) {
        foreach (InputEvent event; events) {
            if (event_.match(event))
                return true;
        }

        return false;
    }
}

/// Gère l’association de certaines entrés avec leurs actions correspondantes
final class InputMap {
    private {
        InputAction[string] _actions;
    }

    @property {

    }

    /// Init
    this() {

    }

    /// Ajoute une nouvelle action
    void addAction(string id, float deadzone) {
        _actions[id] = new InputAction(id, deadzone);
    }

    /// Retire une action existante
    void removeAction(string id) {
        _actions.remove(id);
    }

    /// Vérifie si une action existe
    bool hasAction(string id) const {
        auto p = id in _actions;
        return p !is null;
    }

    /// Associe un événement à une action existante
    void addActionEvent(string id, InputEvent event) {
        auto p = id in _actions;

        if (!p) {
            return;
        }

        (*p).events ~= event;
    }

    /// Supprime un événement associé à une action
    void removeActionEvents(string id, InputEvent event) {
        auto p = id in _actions;

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
    void removeActionEvents(string id) {
        auto p = id in _actions;

        if (!p) {
            return;
        }

        (*p).events.length = 0;
    }

    string[] getActions() {
        return _actions.keys;
    }

    InputAction getAction(InputEvent event) {
        foreach (InputAction action; _actions) {
            if (action.match(event)) {
                return action;
            }
        }

        return null;
    }
}
