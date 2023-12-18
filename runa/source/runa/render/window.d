module runa.render.window;

import std.conv;
import std.stdio;
import std.string;
import std.exception;

import bindbc.sdl;

import runa.core;
import runa.kernel;

/// Window display mode.
enum DisplayMode {
    fullscreen,
    windowed,
    desktop
}

/// Window class
class Window {
    private {
        /// SDL window
        SDL_Window* _target;

        /// SDL renderer
        SDL_Renderer* _sdlRenderer;

        /// Window icon
        SDL_Surface* _icon;

        /// Dipslay mode
        DisplayMode _displayMode = DisplayMode.windowed;

        /// Window size as ints
        vec2u _windowSize;

        /// Screen size as floats
        vec2 _screenSize;

        /// Timing details
        float _previousTime = 0f;
        float _currentTime = 0f;
        float _deltaTime;

        /// Frame counter
        uint counter = 0;
    }

    @property {
        SDL_Window* target() {
            return _target;
        }

        uint width() const {
            return _windowSize.x;
        }

        uint height() const {
            return _windowSize.y;
        }

        /// Maximum dimension of screen
        uint screenMaxDim() const {
            return max(width, height);
        }
        /// Size of the window in pixels
        vec2 screenSize() const {
            return _screenSize;
        }
        /// Delta time
        float deltaTime() const {
            return _deltaTime;
        }
        /// Set title
        void title(string title) {
            SDL_SetWindowTitle(_target, toStringz(title));
        }
        /// Set icon
        void icon(string path) {
            /// Free previous icon if needed
            if (_icon) {
                SDL_FreeSurface(_icon);
            }

            /// Load new icon and set it up
            const(ubyte)[] data = Runa.res.read(path);
            SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void)*) data.ptr, cast(int) data.length);
            _icon = IMG_Load_RW(rw, 1);
            enforce(_icon, "impossible de charger `" ~ path ~ "`");
            SDL_SetWindowIcon(_target, _icon);
        }
    }

    /// Constructor
    this(const vec2u windowSize, string title) {
        // Create SDL window
        _target = SDL_CreateWindow(toStringz(title), SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED, windowSize.x, windowSize.y, SDL_WINDOW_RESIZABLE);
        enforce(_target, "failed to create the window");

        _windowSize = windowSize;
        _screenSize = cast(vec2)(windowSize);
    }

    /// Destructor
    ~this() {
        if (_target) {
            SDL_DestroyWindow(_target);
        }
    }

    /// Update window behavior depending on its flags
    void update() {
        /*const uint flags = SDL_GetWindowFlags(_target);
        if (flags & SDL_WINDOW_MOUSE_FOCUS) {
            SDL_SetRelativeMouseMode(SDL_TRUE);
            SDL_ShowCursor(SDL_DISABLE);
        } else {
            SDL_SetRelativeMouseMode(SDL_FALSE);
            SDL_ShowCursor(SDL_ENABLE);
        }*/
    }

    /// Compute framerate and display window content
    void render() {
        /*_currentTime = getCurrentTimeInMilliseconds() / 1000f;
        _deltaTime = _currentTime - _previousTime;
        counter++;

        if (_deltaTime >= 1f / 30f) {
            const uint FPS = cast(uint)((1f / _deltaTime) * counter);
            const uint ms = cast(uint)((_deltaTime / counter) * 1000f);
            title = "Runa - " ~ to!string(FPS) ~ "FPS / " ~ to!string(ms) ~ "ms";

            _previousTime = _currentTime;
            counter = 0;
        }*/
    }

    void resizeWindow(const vec2u windowSize) {
        _windowSize = windowSize;
        _screenSize = cast(vec2)(windowSize);
        // TODO
    }
}

/// Load SDL
void loadSDL() {
    /// Initilizations
    enforce(SDL_Init(SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_JOYSTICK | SDL_INIT_HAPTIC |
            SDL_INIT_GAMECONTROLLER | SDL_INIT_EVENTS | SDL_INIT_SENSOR) == 0,
        "Could not initialize SDL: " ~ fromStringz(SDL_GetError()));
    enforce(TTF_Init() != -1, "Could not initialize TTF module");
}
