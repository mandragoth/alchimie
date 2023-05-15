module magia.input.inputmap;

import std.algorithm.mutation : remove;
import std.typecons : BitFlags;

import magia.input.inputevent;

/// Gère l’association de certaines entrés avec leurs actions correspondantes
final class InputMap {
    /// Associe une action à un événement
    final class Action {
        /// Nom de l’action
        string id;

        /// Événements activant l’action
        InputEvent[] events;

        /// Etats attendus pour qu'un evenement active l'action
        BitFlags!KeyState expectedStates;

        /// Seuil d’activation de l’action
        double deadzone;

        /// Init
        this(string id_, double deadzone_) {
            id = id_;
            deadzone = deadzone_;
        }

        /// L’événement active-t’il cette action ?
        bool match(InputEvent event_) {
            foreach (InputEvent event; events) {
                // @TODO handle deadzone for axis here
                if (event_.match(event) && stateMatches(event_.state))
                    return true;
            }

            return false;
        }

         /// L’état est-t'il attendu ?
        private bool stateMatches(KeyState state) {
            return cast(bool) expectedStates & state;
        }
    }

    private {
        Action[string] _actions;
    }

    /// Ajoute une nouvelle action
    void addAction(string id, double deadzone = .2f) {
        _actions[id] = new Action(id, deadzone);
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

    /// Retourne l’action
    Action getAction(string id) {
        auto p = id in _actions;
        return p ? *p : null;
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

    /// Associe un état attendu à une action existante
    void addActionExpectedState(string id, KeyState expectedState) {
        auto p = id in _actions;

        if (!p) {
            return;
        }

        (*p).expectedStates |= expectedState;
    }

    /// Associe un set d'états attendus à une action existante
    void addActionExpectedStates(string id, BitFlags!KeyState expectedStates_) {
        auto p = id in _actions;

        if (!p) {
            return;
        }

        (*p).expectedStates = expectedStates_;
    }

    /// Supprime un état attendu associé à une action
    void removeActionExpectedState(string id, KeyState expectedState) {
        auto p = id in _actions;

        if (!p) {
            return;
        }

        (*p).expectedStates = (*p).expectedStates & ~expectedState;
    }

    /// Supprime un set d'états attendus associés à une action
    void removeActionExpectedState(string id, BitFlags!KeyState expectedStates) {
        auto p = id in _actions;

        if (!p) {
            return;
        }

        (*p).expectedStates = (*p).expectedStates & ~expectedStates;
    }

    /// Supprime tous les états attendus associés à une action
    void removeActionExpectedStates(string id) {
        auto p = id in _actions;

        if (!p) {
            return;
        }

        (*p).expectedStates = BitFlags!KeyState();
    }

    string[] getActions() {
        return _actions.keys;
    }

    Action getAction(InputEvent event) {
        foreach (Action action; _actions) {
            if (action.match(event)) {
                return action;
            }
        }

        return null;
    }
}
