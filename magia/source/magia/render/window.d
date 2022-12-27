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
import bindbc.opengl, bindbc.sdl, bindbc.sdl.image, bindbc.sdl.mixer, bindbc.sdl.ttf;
import magia.core, magia.common, magia.render.postprocess;

static {
    /// SDL window
    SDL_Window* _sdlWindow;

    /// SDL context
    SDL_GLContext _glContext;

    private {
        SDL_Surface* _icon;
        vec2u _windowSize;
        vec2 _screenSize, _centerScreen;
        DisplayMode _displayMode = DisplayMode.windowed;
        GLuint _currentShaderProgram;
        float _baseAlpha = 1f;

        double previousTime = 0.0;
        double currentTime = 0.0;
        double deltaTime;

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
    /// Half of the size of the window in pixels.
    vec2 centerScreen() {
        return _centerScreen;
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

/// Loads all libraries and creates the application window
void createWindow(const vec2u windowSize, string title) {
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

    enforce(sdlSupport >= SDLSupport.sdl202, "Failed to load SDL");
    enforce(imageSupport >= SDLImageSupport.sdlImage200, "Failed to load SDLImage");
    enforce(ttfSupport >= SDLTTFSupport.sdlTTF2014, "Failed to load SDLTTF");
    enforce(mixerSupport >= SDLMixerSupport.sdlMixer200, "Failed to load SDLMixer");

    enforce(SDL_Init(SDL_INIT_EVERYTHING) == 0,
        "could not initialize SDL: " ~ fromStringz(SDL_GetError()));

    enforce(TTF_Init() != -1, "could not initialize TTF module");
    enforce(Mix_OpenAudio(44_100, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS,
            1024) != -1, "no audio device connected");
    enforce(Mix_AllocateChannels(16) != -1, "could not allocate audio channels");

    _sdlWindow = SDL_CreateWindow(toStringz(title), SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, windowSize.x, windowSize.y,
        SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
    enforce(_sdlWindow, "failed to create the window");
    _glContext = SDL_GL_CreateContext(_sdlWindow);
    enforce(loadOpenGL() == GLSupport.gl41, "failed to load opengl");

    SDL_GL_MakeCurrent(_sdlWindow, _glContext);

    glViewport(0, 0, windowSize.x, windowSize.y);

    // Enable depth buffer
    glEnable(GL_DEPTH_TEST);

    // Enables multi-samples
    glEnable(GL_MULTISAMPLE);

    // Enable culling
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);

    _windowSize = windowSize;
    _screenSize = cast(vec2)(windowSize);
    _centerScreen = _screenSize / 2f;

    setWindowTitle(title);
}

/// Prepare to render 2D items
void setup2DRender() {
    glDisable(GL_DEPTH_TEST);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    glDisable(GL_CULL_FACE);
}

/// Prepare to render 3D items
void setup3DRender() {
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    glEnable(GL_CULL_FACE);
}

/// Cleanup the application window.
void destroyWindow() {
    if (_sdlWindow) {
        SDL_DestroyWindow(_sdlWindow);
    }
}

/// Change the actual window title.
void setWindowTitle(string title) {
    SDL_SetWindowTitle(_sdlWindow, toStringz(title));
}

/// Resize windows
void resizeWindow(const vec2u windowSize) {
    _windowSize = windowSize;
    _screenSize = cast(vec2)(windowSize);
    _centerScreen = _screenSize / 2f;

    glViewport(0, 0, windowSize.x, windowSize.y);
}

/// Reset viewport
void resetViewport() {
    glViewport(0, 0, _windowSize.x, _windowSize.y);
}

/// Current window size.
vec2i getWindowSize() {
    int width;
    int height;
    SDL_GetWindowSize(_sdlWindow, &width, &height);
    return vec2i(width, height);
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
    Event event;
    event.type = EventType.resize;
    event.window.size = newSize;
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

/// Change coordinate system from inside to outside the canvas.
vec2 transformRenderSpace(const vec2 pos) {
    vec2 size = cast(vec2)(_windowSize);
    vec2 position = size / 2f;

    // @TODO apply canvas scale ratio
	return (pos - position) + size * 0.5f;
}

/// Change the scale from outside to inside the canvas.
vec2 transformScale() {
    // @TODO apply canvas scale ratio
	return vec2.one;
}

/// Sets shader main entry point
void setShaderProgram(GLuint shaderProgram) {
    if (shaderProgram != _currentShaderProgram) {
        _currentShaderProgram = shaderProgram;
        glUseProgram(_currentShaderProgram);
    }
}

void setBaseColor(Color color) {
    bgColor = color;
}

Color getBaseColor() {
    return bgColor;
}

void setBaseAlpha(float alpha) {
    _baseAlpha = alpha;
}

float getBaseAlpha() {
    return _baseAlpha;
}
