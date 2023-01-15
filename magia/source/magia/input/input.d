module magia.input.input;

version (linux) {
    import core.sys.posix.unistd;
    import core.sys.posix.signal;
}
version (Windows) {
    import core.stdc.signal;
}

import std.conv : to, parse;
import std.path, std.string, std.utf;

import bindbc.sdl;

import magia.core, magia.render;

import magia.input.inputevent, magia.input.inputmap;

private shared bool _isRunning = false;

/// Gère les entrés et notifications de l’application
final class Input {
    private {
        InputMap _map;
        bool _hasQuit;
        vec2i _globalMousePosition, _mousePosition;

        bool[InputEvent.KeyButton.Button.max + 1] _keyButtonsPressed;
        bool[InputEvent.MouseButton.Button.max + 1] _mouseButtonsPressed;

        struct Action {
            bool pressed;
        }

        Action[string] _actions;
    }

    @property {
        /// Notifie d’une demande pour quitter l’application
        bool hasQuit() const {
            return _hasQuit;
        }

        /// Vérifie si le presse papier contient quelque chose
        bool hasClipboard() const {
            return cast(bool) SDL_HasClipboardText();
        }
    }

    /// Init
    this() {
        signal(SIGINT, &signalHandler);
        /*_mousePosition = vec2.zero;
        _mouseRelativePosition = vec2.zero;
        initializeControllers();*/

        //SDL_SetRelativeMouseMode(SDL_TRUE);
        //SDL_ShowCursor(SDL_DISABLE);

        input = this;

        _map = new InputMap;
    }

    /// Récupère le contenu du presse-papier
    string getClipboard() const {
        auto clipboard = SDL_GetClipboardText();

        if (!clipboard)
            return "";

        string text = to!string(fromStringz(clipboard));
        SDL_free(clipboard);
        return text;
    }

    /// Renseigne le presse-papier
    void setClipboard(string text) {
        SDL_SetClipboardText(toStringz(text));
    }

    /// Récupère les événements (clavier/souris/manette/etc)
    /// et les événements de la fenêtre (redimmensionnement/glisser-déposer/etc)
    /// et les redistribue sous forme d’InputEvent
    InputEvent[] pollEvents() {
        InputEvent[] events;
        SDL_Event sdlEvent;

        while (SDL_PollEvent(&sdlEvent)) {
            switch (sdlEvent.type) {
            case SDL_QUIT:
                _hasQuit = true;
                break;
            case SDL_KEYDOWN:
                InputEvent event = InputEvent.keyButton( //
                    cast(InputEvent.KeyButton.Button) sdlEvent.key.keysym.scancode,
                    true, //
                    sdlEvent.key.repeat > 0);

                events ~= event;
                break;
            case SDL_KEYUP:
                InputEvent event = InputEvent.keyButton( //
                    cast(InputEvent.KeyButton.Button) sdlEvent.key.keysym.scancode,
                    false, //
                    sdlEvent.key.repeat > 0);

                events ~= event;
                break;
            case SDL_TEXTINPUT:
                string text = to!string(sdlEvent.text.text);
                text.length = stride(text);
                InputEvent event = InputEvent.textInput(text);

                events ~= event;
                break;
            case SDL_MOUSEMOTION:
                _globalMousePosition = vec2i(sdlEvent.motion.x, sdlEvent.motion.y);
                _mousePosition = _globalMousePosition;
                InputEvent event = InputEvent.mouseMotion( //
                    _globalMousePosition, //
                    _mousePosition);

                events ~= event;
                break;
            case SDL_MOUSEBUTTONDOWN:
                _globalMousePosition = vec2i(sdlEvent.button.x, sdlEvent.button.y);
                _mousePosition = _globalMousePosition;
                InputEvent event = InputEvent.mouseButton( //
                    cast(InputEvent.MouseButton.Button) sdlEvent.button.button,
                    true, //
                    sdlEvent.button.clicks, //
                    _globalMousePosition, //
                    _mousePosition);

                events ~= event;
                break;
            case SDL_MOUSEBUTTONUP:
                _globalMousePosition = vec2i(sdlEvent.button.x, sdlEvent.button.y);
                _mousePosition = _globalMousePosition;
                InputEvent event = InputEvent.mouseButton( //
                    cast(InputEvent.MouseButton.Button) sdlEvent.button.button,
                    false, //
                    sdlEvent.button.clicks, //
                    _globalMousePosition, //
                    _mousePosition);

                events ~= event;
                break;
            case SDL_MOUSEWHEEL:
                InputEvent event = InputEvent.mouseWheel( //
                    vec2i(sdlEvent.wheel.x, sdlEvent.wheel.y));

                events ~= event;
                break;
            case SDL_WINDOWEVENT:
                switch (sdlEvent.window.event) {
                case SDL_WINDOWEVENT_RESIZED:
                    resizeWindow(vec2u(sdlEvent.window.data1, sdlEvent.window.data2));
                    break;
                case SDL_WINDOWEVENT_SIZE_CHANGED:
                    break;
                default:
                    break;
                }
                break;
            case SDL_DROPFILE:
                string path = to!string(fromStringz(sdlEvent.drop.file));
                size_t index;
                while (-1 != (index = path.indexOfAny("%"))) {
                    if ((index + 3) > path.length)
                        break;
                    string str = path[index + 1 .. index + 3];
                    const int utfValue = parse!int(str, 16);
                    const char utfChar = to!char(utfValue);

                    if (index == 0)
                        path = utfChar ~ path[3 .. $];
                    else if ((index + 3) == path.length)
                        path = path[0 .. index] ~ utfChar;
                    else
                        path = path[0 .. index] ~ utfChar ~ path[index + 3 .. $];
                }
                SDL_free(sdlEvent.drop.file);

                InputEvent event = InputEvent.dropFile(path);
                events ~= event;
                break;
            case SDL_CONTROLLERDEVICEADDED:
                break;
            case SDL_CONTROLLERDEVICEREMOVED:
                break;
            case SDL_CONTROLLERDEVICEREMAPPED:
                break;
            case SDL_CONTROLLERAXISMOTION:
                break;
            case SDL_CONTROLLERBUTTONDOWN:
                break;
            case SDL_CONTROLLERBUTTONUP:
                break;
            default:
                break;
            }
        }

        _processEvents(events);

        return events;
    }

    private void _processEvents(InputEvent[] events) {
        foreach (event; events) {
            if (event.isAction) {
                InputAction matchingAction = _map.getAction(event);

                if (matchingAction) {
                    auto p = matchingAction.id in _actions;

                    if (p) {
                        (*p).pressed = event.isPressed;
                    }
                    else {
                        Action action;
                        action.pressed = event.isPressed;
                        _actions[matchingAction.id] = action;
                    }
                }
            }
        }
    }

    /// Est-ce que la touche est appuyée ?
    bool isPressed(InputEvent.KeyButton.Button button) const {
        return _keyButtonsPressed[button];
    }

    /// Ditto
    bool isPressed(InputEvent.MouseButton.Button button) const {
        return _mouseButtonsPressed[button];
    }

    /// L’action est-t’elle activé ?
    bool isActionPressed(string id) const {
        auto p = id in _actions;

        if (!p)
            return false;

        return (*p).pressed;
    }
}

/// Ditto
Input input;

/// Capture les interruptions
extern (C) void signalHandler(int sig) nothrow @nogc @system {
    cast(void) sig;

    if (input)
        input._hasQuit = true;
}
