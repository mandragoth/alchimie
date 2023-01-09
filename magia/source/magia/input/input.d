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
        bool _hasQuit;
        vec2i _globalMousePosition, _mousePosition;
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
    }

    /// Returns the content of the clipboard
    string getClipboard() const {
        auto clipboard = SDL_GetClipboardText();

        if (clipboard) {
            string text = to!string(fromStringz(clipboard));
            SDL_free(clipboard);
            return text;
        }
        return "";
    }

    /// Fill the clipboard
    void setClipboard(string text) {
        SDL_SetClipboardText(toStringz(text));
    }

    /// Rècupère les événements (clavier/souris/manette/etc)
    /// et les événements de la fenêtre (redimmensionnement/glisser-déposer/etc)
    /// et les redistribue sous forme d’InputEvent ou WindowEvent
    void poll() {
        SDL_Event sdlEvent;

        while (SDL_PollEvent(&sdlEvent)) {
            switch (sdlEvent.type) {
            case SDL_QUIT:
                _hasQuit = true;
                break;
            case SDL_KEYDOWN:
                InputEventKey event = new InputEventKey( //
                    cast(InputEventKey.Button) sdlEvent.key.keysym.scancode,
                    true, //
                    sdlEvent.key.repeat > 0);

                _dispatchEvent(event);
                break;
            case SDL_KEYUP:
                InputEventKey event = new InputEventKey( //
                    cast(InputEventKey.Button) sdlEvent.key.keysym.scancode,
                    false, //
                    sdlEvent.key.repeat > 0);

                _dispatchEvent(event);
                break;
            case SDL_TEXTINPUT:
                string text = to!string(sdlEvent.text.text);
                text.length = stride(text);
                InputEventText event = new InputEventText(text);

                _dispatchEvent(event);
                break;
            case SDL_MOUSEMOTION:
                _globalMousePosition = vec2i(sdlEvent.motion.x, sdlEvent.motion.y);
                _mousePosition = _globalMousePosition;
                InputEventMouseMotion event = new InputEventMouseMotion( //
                    _globalMousePosition, //
                    _mousePosition);

                _dispatchEvent(event);
                break;
            case SDL_MOUSEBUTTONDOWN:
                _globalMousePosition = vec2i(sdlEvent.button.x, sdlEvent.button.y);
                _mousePosition = _globalMousePosition;
                InputEventMouseButton event = new InputEventMouseButton(_globalMousePosition, //
                    _mousePosition, //
                    cast(InputEventMouseButton.Button) sdlEvent.button.button,
                    true, //
                    sdlEvent.button.clicks);

                _dispatchEvent(event);
                break;
            case SDL_MOUSEBUTTONUP:
                _globalMousePosition = vec2i(sdlEvent.button.x, sdlEvent.button.y);
                _mousePosition = _globalMousePosition;
                InputEventMouseButton event = new InputEventMouseButton(_globalMousePosition, //
                    _mousePosition, //
                    cast(InputEventMouseButton.Button) sdlEvent.button.button,
                    false, //
                    sdlEvent.button.clicks);

                _dispatchEvent(event);
                break;
            case SDL_MOUSEWHEEL:
                InputEventMouseWheel event = new InputEventMouseWheel(_globalMousePosition, //
                    _mousePosition, //
                    vec2i(sdlEvent.wheel.x, sdlEvent.wheel.y));

                _dispatchEvent(event);
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

                InputEventFile event = new InputEventFile(path);

                _dispatchEvent(event);
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
    }

    private void _dispatchEvent(InputEvent event) {

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
