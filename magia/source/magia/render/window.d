module magia.render.window;

import std.conv;
import std.stdio;
import std.string;
import std.exception;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.kernel;
import magia.render.camera;
import magia.render.renderer;

/// Window display mode.
enum DisplayMode {
    fullscreen,
    windowed,
    desktop
}

/// Window class
final class Window {
    private {
        /// SDL window
        SDL_Window* _sdlWindow;

        /// SDL renderer
        SDL_Renderer* _sdlRenderer;

        /// SDL context
        SDL_GLContext _glContext;

        /// Window icon
        SDL_Surface* _icon;

        /// Dipslay mode
        DisplayMode _displayMode = DisplayMode.windowed;

        /// Cameras
        Camera[] _cameras;

        /// Window size as ints
        vec2u _windowSize;

        /// Screen size as floats
        vec2f _screenSize;

        /// Timing details
        float _previousTime = 0f;
        float _currentTime = 0f;
        float _deltaTime;

        /// Frame counter
        uint counter = 0;
    }

    @property {
        /// Width of the window in pixels
        uint screenWidth() const {
            return _windowSize.x;
        }

        /// Height of the window in pixels
        uint screenHeight() const {
            return _windowSize.y;
        }

        /// Maximum dimension of screen
        uint screenMaxDim() const {
            return max(screenWidth, screenHeight);
        }

        /// Size of the window in pixels
        vec2f screenSize() const {
            return _screenSize;
        }

        /// Coordinates for the top left of the screen
        vec2f topLeft() const {
            return vec2f(-_screenSize.x / 2f, _screenSize.y / 2f);
        }

        /// Delta time
        float deltaTime() const {
            return _deltaTime;
        }

        /// Set title
        void title(string title) {
            SDL_SetWindowTitle(_sdlWindow, toStringz(title));
        }
    }

    /// Constructor
    this(const vec2u windowSize, string title) {
        // Create SDL window
        _sdlWindow = SDL_CreateWindow(toStringz(title), SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED, windowSize.x, windowSize.y,
            SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
        enforce(_sdlWindow, "failed to create the window");

        // Create OpenGL context and load OpenGL
        _glContext = SDL_GL_CreateContext(_sdlWindow);
        enforce(loadOpenGL() == glSupport, "Failed to load opengl");

        // Bind openGL context to window
        SDL_GL_MakeCurrent(_sdlWindow, _glContext);

        // Setup opengl debug
        glDebugMessageCallback(&openGLLogMessage, null);
        glEnable(GL_DEBUG_OUTPUT);
        glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);

        // By default set viewport to screen size and clip control 
        glViewport(0, 0, windowSize.x, windowSize.y);
        glClipControl(GL_LOWER_LEFT, GL_NEGATIVE_ONE_TO_ONE);

        _windowSize = windowSize;
        _screenSize = cast(vec2f)(windowSize);
    }

    /// Destructor
    ~this() {
        if (_sdlWindow) {
            SDL_DestroyWindow(_sdlWindow);
        }
    }

    /// Set icon
    void setIcon(string path) {
        /// Free previous icon if needed
        if (_icon) {
            SDL_FreeSurface(_icon);
        }

        /// Load new icon and set it up
        const(ubyte)[] data = Magia.res.read(path);
        SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void)*) data.ptr, cast(int) data.length);
        _icon = IMG_Load_RW(rw, 1);
        enforce(_icon, "impossible de charger `" ~ path ~ "`");
        SDL_SetWindowIcon(_sdlWindow, _icon);
    }

    /// Add camera
    void addCamera(Camera camera) {
        _cameras ~= camera;
    }

    /// Update window behavior depending on its flags
    void update() {
        const uint flags = SDL_GetWindowFlags(_sdlWindow);
        if (flags & SDL_WINDOW_MOUSE_FOCUS) {
            SDL_SetRelativeMouseMode(SDL_TRUE);
            SDL_ShowCursor(SDL_DISABLE);
        } else {
            SDL_SetRelativeMouseMode(SDL_FALSE);
            SDL_ShowCursor(SDL_ENABLE);
        }
    }

    /// Compute framerate and display window content
    void render() {
        /*_currentTime = getCurrentTimeInMilliseconds() / 1000f;
        _deltaTime = _currentTime - _previousTime;
        counter++;

        if (_deltaTime >= 1f / 30f) {
            const uint FPS = cast(uint)((1f / _deltaTime) * counter);
            const uint ms = cast(uint)((_deltaTime / counter) * 1000f);
            title = "Magia - " ~ to!string(FPS) ~ "FPS / " ~ to!string(ms) ~ "ms";

            _previousTime = _currentTime;
            counter = 0;
        }*/

        SDL_GL_SwapWindow(_sdlWindow);
    }

    /// Resize window, viewport and camera aspect ratios
    void resizeWindow(const vec2u windowSize) {
        _windowSize = windowSize;
        _screenSize = cast(vec2f)(windowSize);
        glViewport(0, 0, windowSize.x, windowSize.y);
    }
}

/// SDL and OpenGL load debug flag
bool s_DebugLoad = false;

/// Load SDL and OpenGL
void loadSDLOpenGL() {
    /// Initilizations
    enforce(SDL_Init(SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_JOYSTICK | SDL_INIT_HAPTIC |
            SDL_INIT_GAMECONTROLLER | SDL_INIT_EVENTS | SDL_INIT_SENSOR) == 0,
        "Could not initialize SDL: " ~ fromStringz(SDL_GetError()));
    enforce(TTF_Init() != -1, "Could not initialize TTF module");
}
