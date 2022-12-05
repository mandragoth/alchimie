module magia.ui.manager;

import std.string;
import bindbc.opengl, bindbc.sdl;
import magia.core, magia.render;
import magia.ui.element;
import magia.render.vao;
import magia.render.vbo;

private {
    UIElement[] _roots;
}

private {
    GLuint _shaderProgram, _vertShader, _fragShader;
    GLuint _vao;
    GLint _colorUniform, _modelUniform;
}

/// UI elements manager
class UIManager {
    private {
        VAO _VAO;
        VBO _VBO;
        Shader _shader;

        UIElement[] _elements;

        GLint _modelUniform;
        GLint _colorUniform;
    }

    /// Constructor
    this() {
        // Circle vertices
        vec2[] vertices = [
	        vec2( 1.0f,  1.0f),
	        vec2(-1.0f,  1.0f),
	        vec2( 1.0f, -1.0f),
	        vec2(-1.0f, -1.0f)
        ];

        _VAO = new VAO();
        _VAO.bind();

        _VBO = new VBO(vertices);
        _VAO.linkAttributes(_VBO, 0, 2, GL_FLOAT, vec2.sizeof, null);

        _shader = new Shader("primitive.vert", "primitive.frag");
        _colorUniform = glGetUniformLocation(_shader.id, "color");
        _modelUniform = glGetUniformLocation(_shader.id, "model");
    }

    /// Update
    void update(float deltaTime) {
        foreach (UIElement element; _roots) {
            updateUI(deltaTime, element);
        }
    }

    /// Draw
    void draw() {
        mat4 position = mat4.identity;
        mat4 size = mat4.identity;
        position.translate(-1f, -1f, 0.0f);
        size.scale(1f / screenSize().x, 1f / screenSize().y, 1.0f);

        mat4 transform = position * size;
        foreach (UIElement element; _roots) {
            drawUI(transform, element);
        }
    }

    private void updateUI(float deltaTime, UIElement element) {
        // Compute transitions
        if (element.timer.isRunning) {
            element.timer.update(deltaTime);

            SplineFunc splineFunc = getSplineFunc(element.targetState.spline);
            const float t = splineFunc(element.timer.value01);

            element.offsetX = lerp(element.initState.offsetX, element.targetState.offsetX, t);
            element.offsetY = lerp(element.initState.offsetY, element.targetState.offsetY, t);

            element.scaleX = lerp(element.initState.scaleX, element.targetState.scaleX, t);
            element.scaleY = lerp(element.initState.scaleY, element.targetState.scaleY, t);

            element.angle = lerp(element.initState.angle, element.targetState.angle, t);
            element.alpha = lerp(element.initState.alpha, element.targetState.alpha, t);
        }

        // Update children
        foreach (UIElement child; element._children) {
            updateUI(deltaTime, child);
        }
    }

    private void drawUI(mat4 transform, UIElement element, UIElement parent = null) {
        mat4 local = mat4.identity;

        // Scale
        local.scale(element.scaleX, element.scaleY, 1f);

        // Rotation: translate the element back to 0,0 temporarily
        local.translate(-element.sizeX * element.scaleX * element.pivotX * 2f,
                        -element.sizeY * element.scaleY * element.pivotY * 2f,
                        0f);

        // Rotation
        if (element.angle) {
            local.rotatez(element.angle);
        }

        // Rotation: translate the element back to its pivot
        local.translate(element.sizeX * element.scaleX * element.pivotX * 2f,
                        element.sizeY * element.scaleY * element.pivotY * 2f,
                        0f);

        float x = element.posX + element.offsetX;
        float y = element.posY + element.offsetY;
        
        const float parentW = parent ? parent.sizeX : screenWidth();
        const float parentH = parent ? parent.sizeY : screenHeight();

        final switch (element.alignX) with (UIElement.AlignX) {
            case left:
                break;
            case right:
                x = parentW - (x + (element.sizeX * element.scaleX));
                break;
            case center:
                x = parentW / 2f + x;
                break;
        }

        final switch (element.alignY) with (UIElement.AlignY) {
            case bottom:
                break;
            case top:
                y = parentH - (y + (element.sizeY * element.scaleY));
                break;
            case center:
                y = parentH / 2f + y;
                break;
        }

        // Position
        local.translate(x * 2f, y * 2f, 0f);
        transform = transform * local;

        element.draw(transform);
        foreach (UIElement child; element._children) {
            drawUI(transform, child, element);
        }
    }

    /// Add an UIElement to the manager
    void appendUIElement(UIElement element) {
        _elements ~= element;
    }

    /// Remove all UIElements from the manager
    void removeUIElements() {
        _elements.length = 0;
    }
}

void initUI() {
    // Vertices
    immutable float[] points = [
        1f, 1f, -1f, 1f, 1f, -1f, -1f, -1f
    ];

    GLuint vbo = 0;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, points.length * float.sizeof, points.ptr, GL_STATIC_DRAW);

    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, null);
    glEnableVertexAttribArray(0);

    immutable char* vshader = toStringz("
        #version 400
        in vec2 vp;
        out vec2 st;
        uniform vec2 size;
        uniform vec2 position;

        uniform mat4 model;
        void main() {
            st = vp;
            gl_Position = model * vec4(vp, 0.0, 1.0);
        }");

    immutable char* fshader = toStringz("
        #version 400
        in vec2 st;
        out vec4 frag_color;
        uniform vec4 color;
        void main() {
            frag_color = color;
            if(frag_color.a == 0.0)
                discard;
        }");

    _vertShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(_vertShader, 1, &vshader, null);
    glCompileShader(_vertShader);
    _fragShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(_fragShader, 1, &fshader, null);
    glCompileShader(_fragShader);

    _shaderProgram = glCreateProgram();
    glAttachShader(_shaderProgram, _fragShader);
    glAttachShader(_shaderProgram, _vertShader);
    glLinkProgram(_shaderProgram);
    _colorUniform = glGetUniformLocation(_shaderProgram, "color");
    _modelUniform = glGetUniformLocation(_shaderProgram, "model");
}

void updateUI(float deltaTime) {
    foreach (UIElement element; _roots) {
        updateUI(deltaTime, element);
    }
}

void drawUI() {
    mat4 transform = mat4.identity;
    mat4 a = mat4.identity;
    mat4 b = mat4.identity;
    a.translate(-1f, -1f, 0.0f);
    b.scale(1f / screenSize().x, 1f / screenSize().y, 1.0f);
    transform = a * b;

    foreach (UIElement element; _roots) {
        drawUI(transform, element);
    }
}

void appendRoot(UIElement element) {
    _roots ~= element;
}

void removeRoots() {
    _roots.length = 0;
}

private void updateUI(float deltaTime, UIElement element, UIElement parent = null) {
    // Calcul des transitions
    if (element.timer.isRunning) {
        element.timer.update(deltaTime);

        SplineFunc splineFunc = getSplineFunc(element.targetState.spline);
        const float t = splineFunc(element.timer.value01);

        element.offsetX = lerp(element.initState.offsetX, element.targetState.offsetX, t);
        element.offsetY = lerp(element.initState.offsetY, element.targetState.offsetY, t);

        element.scaleX = lerp(element.initState.scaleX, element.targetState.scaleX, t);
        element.scaleY = lerp(element.initState.scaleY, element.targetState.scaleY, t);

        element.angle = lerp(element.initState.angle, element.targetState.angle, t);
        element.alpha = lerp(element.initState.alpha, element.targetState.alpha, t);

        if (!element.timer.isRunning) {
            //if (element.targetState.callback.length)
            //    element.onCallback(element.targetState.callback);
        }
    }

    foreach (UIElement ui; element._children) {
        updateUI(deltaTime, ui, element);
    }
}

private void drawUI(mat4 transform, UIElement element, UIElement parent = null) {
    mat4 local = mat4.identity;

    local.scale(element.scaleX, element.scaleY, 1f);
    local.translate(
        -element.sizeX * element.scaleX * element.pivotX * 2f,
        -element.sizeY * element.scaleY * element.pivotY * 2f,
        0f);

    if (element.angle)
        local.rotatez(element.angle);

    local.translate(
        element.sizeX * element.scaleX * element.pivotX * 2f,
        element.sizeY * element.scaleY * element.pivotY * 2f,
        0f);

    float x = element.posX + element.offsetX;
    float y = element.posY + element.offsetY;
    float parentW = parent ? parent.sizeX : screenWidth();
    float parentH = parent ? parent.sizeY : screenHeight();

    final switch (element.alignX) with (UIElement.AlignX) {
    case left:
        break;
    case right:
        x = parentW - (x + (element.sizeX * element.scaleX));
        break;
    case center:
        x = parentW / 2f + x;
        break;
    }
    final switch (element.alignY) with (UIElement.AlignY) {
    case bottom:
        break;
    case top:
        y = parentH - (y + (element.sizeY * element.scaleY));
        break;
    case center:
        y = parentH / 2f + y;
        break;
    }
    local.translate(x * 2f, y * 2f, 0f);
    transform = transform * local;

    element.draw(transform);
    foreach (UIElement child; element._children) {
        drawUI(transform, child, element);
    }
}