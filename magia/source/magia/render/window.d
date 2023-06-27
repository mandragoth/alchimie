module magia.render.window;

import std.conv;
import std.stdio;
import std.string;
import std.exception;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.render.camera;
import magia.render.renderer;

/// Window display mode.
enum DisplayMode {
    fullscreen,
    windowed,
    desktop
}

/// Main window
Window window;

/// Window class
class Window {
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
        vec2 screenSize() const {
            return _screenSize;
        }
        /// Delta time
        float deltaTime() const {
            return _deltaTime;
        }
        /// Set title
        void title(string title) {
            SDL_SetWindowTitle(_sdlWindow, toStringz(title));
        }
        /// Set icon
        void icon(string path) {
            /// Free previous icon if needed
            if (_icon) {
                SDL_FreeSurface(_icon);
            }

            /// Load new icon and set it up
            _icon = IMG_Load(toStringz(path));
            SDL_SetWindowIcon(_sdlWindow, _icon);
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

        SDL_GL_MakeCurrent(_sdlWindow, _glContext);

        // By default set viewport to screen size and clip control 
        glViewport(0, 0, windowSize.x, windowSize.y);
        glClipControl(GL_LOWER_LEFT, GL_NEGATIVE_ONE_TO_ONE);

        _windowSize = windowSize;
        _screenSize = cast(vec2)(windowSize);
    }

    /// Destructor
    ~this() {
        if (_sdlWindow) {
            SDL_DestroyWindow(_sdlWindow);
        }
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
        _currentTime = getCurrentTimeInMilliseconds() / 1000f;
        _deltaTime = _currentTime - _previousTime;
        counter++;

        if (_deltaTime >= 1f / 30f) {
            const uint FPS = cast(uint)((1f / _deltaTime) * counter);
            const uint ms = cast(uint)((_deltaTime / counter) * 1000f);
            title = "Magia - " ~ to!string(FPS) ~ "FPS / " ~ to!string(ms) ~ "ms";

            _previousTime = _currentTime;
            counter = 0;
        }

        SDL_GL_SwapWindow(_sdlWindow);
    }

    /// Resize window, viewport and camera aspect ratios
    void resizeWindow(const vec2u windowSize) {
        _windowSize = windowSize;
        _screenSize = cast(vec2)(windowSize);

        glViewport(0, 0, windowSize.x, windowSize.y);

        foreach (Camera camera; renderer.cameras) {
            camera.aspectRatio = getAspectRatio();
        }
    }

    /// Aspect ratio
    float getAspectRatio() {
        return _screenSize.x / _screenSize.y;
    }
}

/// SDL and OpenGL load debug flag
bool s_DebugLoad = false;

/// Load SDL and OpenGL
void loadSDLOpenGL() {
    SDLSupport sdlSupport = loadSDL();
    SDLImageSupport imageSupport = loadSDLImage();
    SDLTTFSupport ttfSupport = loadSDLTTF();
    SDLMixerSupport mixerSupport = loadSDLMixer();

    if (s_DebugLoad) {
        writeln(sdlSupport);
        writeln(imageSupport);
        writeln(ttfSupport);
        writeln(mixerSupport);
    }

    /// SDL load
    enforce(sdlSupport >= SDLSupport.sdl202, "Failed to load SDL");
    enforce(imageSupport >= SDLImageSupport.sdlImage200, "Failed to load SDLImage");
    enforce(ttfSupport >= SDLTTFSupport.sdlTTF2014, "Failed to load SDLTTF");
    enforce(mixerSupport >= SDLMixerSupport.sdlMixer200, "Failed to load SDLMixer");

    /// Initilizations
    enforce(SDL_Init(SDL_INIT_EVERYTHING) == 0, "Could not initialize SDL: " ~ fromStringz(SDL_GetError()));
    enforce(TTF_Init() != -1, "Could not initialize TTF module");
    enforce(Mix_OpenAudio(44_100, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 1024) != -1, "No audio device connected");
    enforce(Mix_AllocateChannels(16) != -1, "Could not allocate audio channels");
}