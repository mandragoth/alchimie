/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module magia.render.window;

import std.conv;
import std.stdio;
import std.string;
import std.exception;

import bindbc.opengl;
import bindbc.sdl;

import magia.core;
import magia.render.camera;
import magia.render.postprocess;
import magia.render.renderer;

static {
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

        /// Is VSync activates?
        bool _vsync;

        /// Timing details
        double previousTime = 0.0;
        double currentTime = 0.0;
        double deltaTime;

        /// Frame counter
        uint counter = 0;
    }
}

@property {
    /// Width of the window in pixels.
    uint screenWidth() {
        return _windowSize.x;
    }
    /// Height of the window in pixels.
    uint screenHeight() {
        return _windowSize.y;
    }
    /// Maximum dimension of screen
    uint screenMaxDim() {
        return max(screenWidth, screenHeight);
    }
    /// Size of the window in pixels.
    vec2 screenSize() {
        return _screenSize;
    }
    /// Set vsync
    void vsync(bool vsync) {
        _vsync = vsync;
    }
    /// SDL window
    SDL_Window* window() {
        return _sdlWindow;
    }
}

/// Window display mode.
enum DisplayMode {
    fullscreen,
    desktop,
    windowed
}

/// Set to true to debug load
const bool debugLoad = false;

/// Load SDL and OpenGL (@TODO move)
void loadSDLOpenGL() {
    SDLSupport sdlSupport = loadSDL();
    SDLImageSupport imageSupport = loadSDLImage();
    SDLTTFSupport ttfSupport = loadSDLTTF();
    SDLMixerSupport mixerSupport = loadSDLMixer();

    if (debugLoad) {
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

/// Loads all libraries and creates the application window
void createWindow(const vec2u windowSize, string title) {
    // Create SDL window
    _sdlWindow = SDL_CreateWindow(toStringz(title), SDL_WINDOWPOS_CENTERED,
                                  SDL_WINDOWPOS_CENTERED, windowSize.x, windowSize.y,
                                  SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
    enforce(_sdlWindow, "failed to create the window");

    // Create OpenGL context and load OpenGL
    _glContext = SDL_GL_CreateContext(_sdlWindow);
    enforce(loadOpenGL() == glSupport, "Failed to load opengl");

    SDL_GL_MakeCurrent(_sdlWindow, _glContext);

    glViewport(0, 0, windowSize.x, windowSize.y);
    glClipControl(GL_LOWER_LEFT, GL_NEGATIVE_ONE_TO_ONE);

    // @TODO toggle
    SDL_SetRelativeMouseMode(SDL_TRUE);
    SDL_ShowCursor(SDL_DISABLE);

    _windowSize = windowSize;
    _screenSize = cast(vec2)(windowSize);

    setWindowTitle(title);
}

/// Cleanup the application window.
void destroyWindow() {
    if (_sdlWindow) {
        SDL_DestroyWindow(_sdlWindow);
    }
}

/// Change the actual window title
/// @TODO to script
void setWindowTitle(string title) {
    SDL_SetWindowTitle(_sdlWindow, toStringz(title));
}

/// Resize windows
void resizeWindow(const vec2u windowSize) {
    _windowSize = windowSize;
    _screenSize = cast(vec2)(windowSize);

    glViewport(0, 0, windowSize.x, windowSize.y);

    foreach (Camera camera; renderer.cameras) {
        camera.aspectRatio = getAspectRatio();
    }
}

/// Current window size.
vec2i getWindowSize() {
    int width;
    int height;
    SDL_GetWindowSize(_sdlWindow, &width, &height);
    return vec2i(width, height);
}

/// Aspect ratio
float getAspectRatio() {
    return _screenSize.x / _screenSize.y;
}

/// The window cannot be resized less than this.
void setWindowMinSize(vec2u size) {
    SDL_SetWindowMinimumSize(_sdlWindow, size.x, size.y);
}

/// The window cannot be resized more than this.
void setWindowMaxSize(vec2u size) {
    SDL_SetWindowMaximumSize(_sdlWindow, size.x, size.y);
}

/// Change the icon displayed.
void setWindowIcon(string path) {
    if (_icon) {
        SDL_FreeSurface(_icon);
        _icon = null;
    }
    _icon = IMG_Load(toStringz(path));

    SDL_SetWindowIcon(_sdlWindow, _icon);
}

/// Change the display mode between windowed, desktop fullscreen and fullscreen.
void setWindowDisplay(DisplayMode displayMode) {
    _displayMode = displayMode;
    SDL_WindowFlags mode;
    final switch (displayMode) with (DisplayMode) {
    case fullscreen:
        mode = SDL_WINDOW_FULLSCREEN;
        break;
    case desktop:
        mode = SDL_WINDOW_FULLSCREEN_DESKTOP;
        break;
    case windowed:
        mode = cast(SDL_WindowFlags) 0;
        break;
    }
    SDL_SetWindowFullscreen(_sdlWindow, mode);
    vec2u newSize = cast(vec2u) getWindowSize();
    resizeWindow(newSize);
}

/// Current display mode.
DisplayMode getWindowDisplay() {
    return _displayMode;
}

/// Enable/Disable the borders.
void setWindowBordered(bool bordered) {
    SDL_SetWindowBordered(_sdlWindow, bordered ? SDL_TRUE : SDL_FALSE);
}

/// Show/Hide the window.
/// Shown by default.
void showWindow(bool show) {
    if (show) {
        SDL_ShowWindow(_sdlWindow);
    }
    else {
        SDL_HideWindow(_sdlWindow);
    }
}

/// Render everything on screen.
void renderWindow() {
    currentTime = SDL_GetTicks() / 1000;
    deltaTime = currentTime - previousTime;
    counter++;

    if (deltaTime >= 1.0 / 30.0) {
        const double FPS = (1.0 / deltaTime) * counter;
        const double ms = (deltaTime / counter) * 1000;
        const string newTitle = "Magia - " ~ to!string(FPS) ~ "FPS / " ~ to!string(ms) ~ "ms";
        setWindowTitle(newTitle);

        previousTime = currentTime;
        counter = 0;
    }

    SDL_GL_SwapWindow(_sdlWindow);
}

void setBaseColor(Color color) {
    bgColor = color;
}

Color getBaseColor() {
    return bgColor;
}

void setBaseAlpha(float alpha) {
    bgAlpha = alpha;
}

float getBaseAlpha() {
    return bgAlpha;
}
