module magia.input.input;

version (linux) {
    import core.sys.posix.unistd;
    import core.sys.posix.signal;
}
version (Windows) {
    import core.stdc.signal;
}

import std.file : exists;
import std.conv : to, parse;
import std.path, std.string, std.utf;

import bindbc.sdl;

import magia.core, magia.render;

import magia.input.inputevent, magia.input.inputmap;

/// Gère les entrés et notifications de l’application
final class Input {
    private {
        final class Controller {
            SDL_GameController* sdlController;
            SDL_Joystick* sdlJoystick;
            int index, joystickId;
        }

        InputMap _map;
        bool _hasQuit;

        Controller[] _controllers;

        vec2i _globalMousePosition, _mousePosition;

        bool[InputEvent.KeyButton.Button.max + 1] _keyButtonsPressed;
        bool[InputEvent.MouseButton.Button.max + 1] _mouseButtonsPressed;
        bool[InputEvent.ControllerButton.Button.max + 1] _controllerButtonsPressed;
        double[InputEvent.ControllerAxis.Axis.max + 1] _controllerAxisValues = .0;

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
        signal(SIGINT, &_signalHandler);
        _globalMousePosition = vec2i.zero;
        _mousePosition = vec2i.zero;

        // Initialise toutes les manettes connectées
        foreach (index; 0 .. SDL_NumJoysticks())
            _addController(index);
        SDL_GameControllerEventState(SDL_ENABLE);

        //SDL_SetRelativeMouseMode(SDL_TRUE);
        //SDL_ShowCursor(SDL_DISABLE);

        _input = this;

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
                InputEvent.KeyButton.Button button = cast(
                    InputEvent.KeyButton.Button) sdlEvent.key.keysym.scancode;

                if (button > InputEvent.KeyButton.Button.max)
                    break;

                _keyButtonsPressed[button] = true;

                events ~= InputEvent.keyButton(button, true, sdlEvent.key.repeat > 0);
                break;
            case SDL_KEYUP:
                InputEvent.KeyButton.Button button = cast(
                    InputEvent.KeyButton.Button) sdlEvent.key.keysym.scancode;

                if (button > InputEvent.KeyButton.Button.max)
                    break;

                _keyButtonsPressed[button] = false;

                events ~= InputEvent.keyButton(button, false, sdlEvent.key.repeat > 0);
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
                InputEvent.MouseButton.Button button = cast(
                    InputEvent.MouseButton.Button) sdlEvent.button.button;

                if (button > InputEvent.MouseButton.Button.max)
                    break;

                _globalMousePosition = vec2i(sdlEvent.button.x, sdlEvent.button.y);
                _mousePosition = _globalMousePosition;

                _mouseButtonsPressed[button] = true;

                events ~= InputEvent.mouseButton(button, true,
                    sdlEvent.button.clicks, _globalMousePosition, _mousePosition);
                break;
            case SDL_MOUSEBUTTONUP:
                InputEvent.MouseButton.Button button = cast(
                    InputEvent.MouseButton.Button) sdlEvent.button.button;

                if (button > InputEvent.MouseButton.Button.max)
                    break;

                _globalMousePosition = vec2i(sdlEvent.button.x, sdlEvent.button.y);
                _mousePosition = _globalMousePosition;

                _mouseButtonsPressed[button] = false;

                events ~= InputEvent.mouseButton(button, false,
                    sdlEvent.button.clicks, _globalMousePosition, _mousePosition);
                break;
            case SDL_MOUSEWHEEL:
                InputEvent event = InputEvent.mouseWheel( //
                    vec2i(sdlEvent.wheel.x, sdlEvent.wheel.y));

                events ~= event;
                break;
            case SDL_CONTROLLERDEVICEADDED:
                _addController(sdlEvent.cdevice.which);
                break;
            case SDL_CONTROLLERDEVICEREMOVED:
                _removeController(sdlEvent.cdevice.which);
                break;
            case SDL_CONTROLLERDEVICEREMAPPED:
                break;
            case SDL_CONTROLLERAXISMOTION:
                InputEvent.ControllerAxis.Axis axis = cast(
                    InputEvent.ControllerAxis.Axis) sdlEvent.caxis.axis;

                if (axis > InputEvent.ControllerAxis.Axis.max)
                    break;

                const double value = rlerp(-32_768, 32_767, cast(double) sdlEvent.caxis.value) *
                    2f - 1f;
                _controllerAxisValues[axis] = value;

                events ~= InputEvent.controllerAxis(axis, value);
                break;
            case SDL_CONTROLLERBUTTONDOWN:
                InputEvent.ControllerButton.Button button = cast(
                    InputEvent.ControllerButton.Button) sdlEvent.cbutton.button;

                if (button > InputEvent.ControllerButton.Button.max)
                    break;

                _controllerButtonsPressed[button] = true;

                events ~= InputEvent.controllerButton(button, true);
                break;
            case SDL_CONTROLLERBUTTONUP:
                InputEvent.ControllerButton.Button button = cast(
                    InputEvent.ControllerButton.Button) sdlEvent.cbutton.button;

                if (button > InputEvent.ControllerButton.Button.max)
                    break;

                _controllerButtonsPressed[button] = false;

                events ~= InputEvent.controllerButton(button, false);
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
            default:
                break;
            }
        }

        _processEvents(events);

        return events;
    }

    /// Enregistre toutes les définitions de manettes depuis un fichier valide
    private void _addControllerMappingsFromFile(string filePath) {
        if (!exists(filePath))
            throw new Exception("could not find `" ~ filePath ~ "`");
        if (-1 == SDL_GameControllerAddMappingsFromFile(toStringz(filePath)))
            throw new Exception("invalid mapping file `" ~ filePath ~ "`");
    }

    /// Enregistre une définition de manette
    private void _addControllerMapping(string mapping) {
        if (-1 == SDL_GameControllerAddMapping(toStringz(mapping)))
            throw new Exception("Invalid mapping.");
    }

    /// Ajoute une manette connectée
    private void _addController(int index) {
        //writeln("Detected device at index ", index, ".");

        auto c = SDL_JoystickNameForIndex(index);
        auto d = fromStringz(c);
        //writeln("Device name: ", d);

        if (!SDL_IsGameController(index)) {
            //writeln("The device is not recognised as a game controller.");
            auto stick = SDL_JoystickOpen(index);
            auto guid = SDL_JoystickGetGUID(stick);
            //writeln("The device guid is: ");
            //foreach (i; 0 .. 16)
            //    printf("%02x", guid.data[i]);
            //writeln("");
            return;
        }
        //writeln("The device has been detected as a game controller.");
        foreach (controller; _controllers) {
            if (controller.index == index) {
                //writeln("The controller is already open, aborted.");
                return;
            }
        }

        auto sdlController = SDL_GameControllerOpen(index);
        if (!sdlController) {
            //writeln("Could not connect the game controller.");
            return;
        }

        Controller controller = new Controller;
        controller.sdlController = sdlController;
        controller.index = index;
        controller.sdlJoystick = SDL_GameControllerGetJoystick(controller.sdlController);
        controller.joystickId = SDL_JoystickInstanceID(controller.sdlJoystick);
        _controllers ~= controller;

        //writeln("The game controller is now connected.");
    }

    /// Retire une manette déconnectée
    private void _removeController(int joystickId) {
        //writeln("Controller disconnected: ", joystickId);

        int index;
        bool isControllerPresent;
        foreach (ref controller; _controllers) {
            if (controller.joystickId == joystickId) {
                isControllerPresent = true;
                break;
            }
            index++;
        }

        if (!isControllerPresent)
            return;

        SDL_GameControllerClose(_controllers[index].sdlController);

        //Remove from list
        if (index + 1 == _controllers.length)
            _controllers.length--;
        else if (index == 0)
            _controllers = _controllers[1 .. $];
        else
            _controllers = _controllers[0 .. index] ~ _controllers[(index + 1) .. $];
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

    /// Ditto
    bool isPressed(InputEvent.ControllerButton.Button button) const {
        return _controllerButtonsPressed[button];
    }

    /// Retourne la valeur de l’axe
    double getAxis(InputEvent.ControllerAxis.Axis axis) const {
        return _controllerAxisValues[axis];
    }

    /// L’action est-t’elle activée ?
    bool isActionPressed(string id) const {
        auto p = id in _actions;

        if (!p)
            return false;

        return (*p).pressed;
    }
}

/// Ditto
private Input _input;

/// Capture les interruptions
private extern (C) void _signalHandler(int sig) nothrow @nogc @system {
    cast(void) sig;

    if (_input)
        _input._hasQuit = true;
}
