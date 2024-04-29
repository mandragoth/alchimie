module magia.ui.core.element;

import grimoire;
import magia.core;
import magia.kernel;
import magia.render;
import magia.ui.core.manager;

/// Alignement horizontal
enum UIAlignX {
    left,
    center,
    right
}

/// Alignement vertical
enum UIAlignY {
    top,
    center,
    bottom
}

/// Élément d’interface
class UIElement : Instance2D, Drawable2D {
    private {
        alias NativeEventListener = void delegate();

        UIManager _manager;
        UIElement _parent;
        Array!UIElement _children;
        Array!Sprite _images;
        Array!NativeEventListener[string] _nativeEventListeners;
        Array!GrEvent[string] _scriptEventListeners;

        UIAlignX _alignX = UIAlignX.center;
        UIAlignY _alignY = UIAlignY.center;

        vec2f _position = vec2f.zero;
        vec2f _size = vec2f.zero;
        vec2f _pivot = vec2f.half;
        vec2f _mousePosition = vec2f.zero;

        bool _isHovered, _hasFocus, _isPressed, _isSelected, _isActive, _isGrabbed;
        bool _isEnabled = true;
        bool _isAlive;
        bool _widthLock, _heightLock;
        bool _isVisible = true;
    }

    /// Ordenancement
    int zOrder = 0;

    static final class State {
        string name;
        vec2f offset = vec2f.zero;
        vec2f scale = vec2f.one;
        Color color = Color.white;
        float alpha = 1f;
        double angle = 0.0;
        int time = 60;
        Spline spline = Spline.linear;

        this(string name_) {
            name = name_;
        }
    }

    // Transitions
    vec2f offset = vec2f.zero;
    vec2f scale = vec2f.one;
    Color color = Color.white;
    float alpha = 1f;
    double angle = 0.0;

    package {
        // États
        State[string] states;
        string currentStateName;
        State initState, targetState;
        Timer timer;
    }

    // Propriétés
    @property {
        final bool isAlive() const {
            return _isAlive;
        }

        package final bool isAlive(bool isAlive_) {
            if (_isAlive != isAlive_) {
                _isAlive = isAlive_;
                dispatchEvent(_isAlive ? "register" : "unregister", false);
            }
            return _isAlive = isAlive_;
        }

        final bool isHovered() const {
            return _isHovered;
        }

        package final bool isHovered(bool isHovered_) {
            if (_isHovered != isHovered_) {
                _isHovered = isHovered_;
                dispatchEvent(_isHovered ? "mouseenter" : "mouseleave", false);
                dispatchEvent(_isHovered ? "mouseenterinside" : "mouseleaveinside", true);
            }
            return _isHovered;
        }

        final bool hasFocus() const {
            return _hasFocus;
        }

        final bool hasFocus(bool hasFocus_) {
            if (_hasFocus != hasFocus_) {
                _hasFocus = hasFocus_;
                dispatchEvent(_hasFocus ? "focus" : "blur", false);
            }
            return _hasFocus;
        }

        final bool isPressed() const {
            return _isPressed;
        }

        package final bool isPressed(bool isPressed_) {
            if (_isPressed != isPressed_) {
                _isPressed = isPressed_;
                dispatchEvent(_isPressed ? "press" : "unpress", true);
            }
            return _isPressed;
        }

        final bool isSelected() const {
            return _isSelected;
        }

        final bool isSelected(bool isSelected_) {
            if (_isSelected != isSelected_) {
                _isSelected = isSelected_;
                dispatchEvent(_isSelected ? "select" : "deselect", false);
            }
            return _isSelected;
        }

        final bool isActive() const {
            return _isActive;
        }

        final bool isActive(bool isActive_) {
            if (_isActive != isActive_) {
                _isActive = isActive_;
                dispatchEvent(_isActive ? "active" : "inactive", false);
            }
            return _isActive;
        }

        final bool isGrabbed() const {
            return _isGrabbed;
        }

        package final bool isGrabbed(bool isGrabbed_) {
            if (_isGrabbed != isGrabbed_) {
                _isGrabbed = isGrabbed_;
                dispatchEvent(_isGrabbed ? "grab" : "ungrab", false);
            }
            return _isGrabbed;
        }

        final bool isEnabled() const {
            return _isEnabled;
        }

        final bool isEnabled(bool isEnabled_) {
            if (_isEnabled != isEnabled_) {
                _isEnabled = isEnabled_;
                dispatchEvent(_isEnabled ? "enable" : "disable", false);
            }
            return _isEnabled;
        }

        final bool isVisible() const {
            return _isVisible;
        }

        final bool isVisible(bool isVisible_) {
            if (_isVisible != isVisible_) {
                _isVisible = isVisible_;
                dispatchEvent(_isVisible ? "visible" : "hidden", false);
            }
            return _isVisible;
        }
    }

    bool focusable, movable;

    this() {
        _children = new Array!UIElement;
        _images = new Array!Sprite;
    }

    final UIManager getManager() {
        return _manager;
    }

    package final void setManager(UIManager manager) {
        _manager = manager;
        foreach (child; getChildren()) {
            child.setManager(manager);
        }
    }

    final UIElement getParent() {
        return _parent;
    }

    final vec2f getParentSize() const {
        if (_parent) {
            return _parent._size;
        }
        return Magia.window.screenSize();
    }

    final float getParentWidth() const {
        if (_parent) {
            return _parent._size.x;
        }
        return Magia.window.screenWidth();
    }

    final float getParentHeight() const {
        if (_parent) {
            return _parent._size.y;
        }
        return Magia.window.screenHeight();
    }

    final Array!UIElement getChildren() {
        return _children;
    }

    final Array!Sprite getImages() {
        return _images;
    }

    final vec2f getMousePosition() const {
        return _mousePosition;
    }

    final package vec2f setMousePosition(vec2f mousePosition) {
        return _mousePosition = mousePosition;
    }

    final void setAlign(UIAlignX alignX, UIAlignY alignY) {
        _alignX = alignX;
        _alignY = alignY;
    }

    final UIAlignX getAlignX() const {
        return _alignX;
    }

    final UIAlignY getAlignY() const {
        return _alignY;
    }

    final vec2f getElementOrigin() const {
        vec2f position = getPosition() + offset;

        if (_manager && _manager.isSceneUI && !_parent) {
            return _manager.cameraPosition + position - getSize() * scale * 0.5f;
        }

        const vec2f parentSize = getParentSize();

        final switch (getAlignX()) with (UIAlignX) {
        case left:
            break;
        case right:
            position.x = parentSize.x - (position.x + (getWidth() * scale.x));
            break;
        case center:
            position.x = (parentSize.x / 2f + position.x) - (getSize().x * scale.x) / 2f;
            break;
        }

        final switch (getAlignY()) with (UIAlignY) {
        case top:
            break;
        case bottom:
            position.y = parentSize.y - (position.y + (getHeight() * scale.y));
            break;
        case center:
            position.y = (parentSize.y / 2f + position.y) - (getSize().y * scale.y) / 2f;
            break;
        }

        return position;
    }

    final vec2f getAbsolutePosition() const {
        vec2f position = vec2f.zero;
        if (_parent) {
            position = _parent.getAbsolutePosition();
        }
        position += getElementOrigin();
        return position;
    }

    final vec2f getPosition() const {
        return _position;
    }

    final void setPosition(vec2f position_) {
        if (_position == position_)
            return;
        _position = position_;
        dispatchEvent("position", false);
    }

    final vec2f getSize() const {
        return _size;
    }

    final float getWidth() const {
        return _size.x;
    }

    final float getHeight() const {
        return _size.y;
    }

    final void setSize(vec2f size_) {
        if (_size == size_)
            return;

        bool isDirty;

        if (!_widthLock && _size.x != size_.x) {
            isDirty = true;
            _size.x = size_.x;
        }

        if (!_heightLock && _size.y != size_.y) {
            isDirty = true;
            _size.y = size_.y;
        }

        if (isDirty) {
            dispatchEvent("size", false);
            dispatchEventChildren("parentSize", false);
        }
    }

    final void setWidth(float width_) {
        if (_widthLock || _size.x == width_)
            return;
        _size.x = width_;
        dispatchEvent("size", false);
        dispatchEventChildren("parentSize");
    }

    final void setHeight(float height_) {
        if (_heightLock || _size.y == height_)
            return;
        _size.y = height_;
        dispatchEvent("size", false);
        dispatchEventChildren("parentSize");
    }

    final void setSizeLock(bool width, bool height) {
        _widthLock = width;
        _heightLock = height;
    }

    final vec2f getCenter() const {
        return _size / 2f;
    }

    final vec2f getPivot() const {
        return _pivot;
    }

    final void setPivot(vec2f pivot_) {
        if (_pivot == pivot_)
            return;
        _pivot = pivot_;
        dispatchEvent("pivot", false);
    }

    final void focus() {
        if (_manager) {
            _manager.setFocus(this);
        }
    }

    final void addState(State state) {
        states[state.name] = state;
    }

    final string getState() {
        return currentStateName;
    }

    final void setState(string name) {
        const auto ptr = name in states;
        if (!ptr) {
            return;
        }

        currentStateName = ptr.name;
        initState = null;
        targetState = null;
        offset = ptr.offset;
        scale = ptr.scale;
        color = ptr.color;
        angle = ptr.angle;
        alpha = ptr.alpha;
        timer.stop();
    }

    final void runState(string name) {
        auto ptr = name in states;
        if (!ptr) {
            return;
        }

        currentStateName = ptr.name;
        initState = new State("");
        initState.offset = offset;
        initState.scale = scale;
        initState.angle = angle;
        initState.alpha = alpha;
        initState.time = timer.duration;
        targetState = *ptr;
        timer.start(ptr.time);
    }

    final void addEventListener(string type, NativeEventListener listener) {
        _nativeEventListeners.update(type, {
            Array!NativeEventListener evllist = new Array!NativeEventListener;
            evllist ~= listener;
            return evllist;
        }, (Array!NativeEventListener evllist) { evllist ~= listener; });
    }

    final void addEventListener(string type, GrEvent listener) {
        _scriptEventListeners.update(type, {
            Array!GrEvent evllist = new Array!GrEvent;
            evllist ~= listener;
            return evllist;
        }, (Array!GrEvent evllist) { evllist ~= listener; });
    }

    final void removeEventListener(string type, NativeEventListener listener) {
        _nativeEventListeners.update(type, {
            return new Array!NativeEventListener;
        }, (Array!NativeEventListener evllist) {
            foreach (i, eventListener; evllist) {
                if (eventListener == listener)
                    evllist.mark(i);
            }
            evllist.sweep(true);
        });
    }

    final void removeEventListener(string type, GrEvent listener) {
        _scriptEventListeners.update(type, { return new Array!GrEvent; }, (Array!GrEvent evllist) {
            foreach (i, eventListener; evllist) {
                if (eventListener == listener)
                    evllist.mark(i);
            }
            evllist.sweep(true);
        });
    }

    final void dispatchEvent(string type, bool bubbleUp = true) {
        { // Natifs
            auto p = type in _nativeEventListeners;
            if (p) {
                Array!NativeEventListener evllist = *p;
                foreach (listener; evllist) {
                    listener();
                }
            }
        }

        { // Scripts
            auto p = type in _scriptEventListeners;
            if (p) {
                Array!GrEvent evllist = *p;
                foreach (listener; evllist) {
                    Magia.vm.callEvent(listener);
                }
            }
        }

        if (bubbleUp && _parent) {
            _parent.dispatchEvent(type);
        }
    }

    final void dispatchEventChildren(string type, bool bubbleDown = true) {
        if (bubbleDown) {
            foreach (UIElement child; _children) {
                child.dispatchEvent(type, false);
                child.dispatchEventChildren(type, bubbleDown);
            }
        } else {
            foreach (UIElement child; _children) {
                child.dispatchEvent(type, false);
            }
        }
    }

    final void addUI(UIElement element) {
        if (element.isAlive)
            return;

        element.setManager(_manager);
        element._parent = this;
        element.isAlive = true;
        _children ~= element;
    }

    final void clearUI() {
        foreach (child; _children) {
            child.remove();
        }
        _children.clear();
    }

    final void addImage(Sprite image) {
        _images ~= image;
    }

    final void clearImages() {
        _images.clear();
    }

    final void remove() {
        isAlive = false;
        setManager(null);
        _parent = null;
    }

    void draw(Renderer2D) {}
}

/// Abstract class representing an UI element
/*abstract class UIElement : Instance2D, Drawable2D, Updatable {
    /// Size
    vec2f size = vec2f.zero;

    /// Pivot point
    vec2f pivot = vec2f.one * .5f;

    /// X alignment
    enum AlignX {
        left,
        center,
        right
    }

    /// Y alignment
    enum AlignY {
        top,
        center,
        bottom
    }

    /// Alignment on the X axis
    AlignX alignX = AlignX.left;

    /// Alignment on the Y axis
    AlignY alignY = AlignY.top;

    /// Offset
    vec2f offset = vec2f.zero;

    /// Alpha
    float alpha = 1f;

    /// State of element
    static final class State {
        /// Name of state
        string name;

        /// Initial transform
        Transform2D transform;

        /// Offset to set
        vec2f offset = vec2f.zero;

        /// Alpha to set
        float alpha = 1f;

        /// Ticks for transition
        uint ticks = 60;

        /// Spline used for transition interpolation
        Spline spline = Spline.linear;
    }

    /// States indexed by name
    State[string] states;

    /// Current state
    string currentStateName;

    /// Initial and target states
    State initState, targetState;

    /// Internal timer
    Timer timer;

    /// Propriétés
    bool isHovered, isClicked;

    /// Update
    void update() {
        // Compute transitions
        if (timer.isRunning) {
            timer.update();

            SplineFunc splineFunc = getSplineFunc(targetState.spline);
            const float t = splineFunc(timer.value01);

            offset.x = lerp(initState.offset.x, targetState.offset.x, t);
            offset.y = lerp(initState.offset.y, targetState.offset.y, t);

            transform.scale.x = lerp(initState.transform.scale.x, targetState.transform.scale.x, t);
            transform.scale.y = lerp(initState.transform.scale.y, targetState.transform.scale.y, t);

            transform.rotation.angle = lerp(initState.transform.rotation.angle, targetState.transform.rotation.angle, t);
            alpha = lerp(initState.alpha, targetState.alpha, t);
        }
    }

    /// Draw
    void draw(Renderer2D renderer) {
        // Position
        vec2f position = transform.position + offset;

        // Rotation
        rot2f rotation = transform.rotation;

        // Scale
        vec2f scale = transform.scale;

        UIElement parentElement = cast(UIElement) parent;
        
        const float parentW = parentElement ? parentElement.size.x : renderer.window.screenWidth();
        const float parentH = parentElement ? parentElement.size.y : renderer.window.screenHeight();

        final switch (alignX) with (UIElement.AlignX) {
            case left:
                break;
            case right:
                position.x = parentW - (position.x + (size.x * scale.x));
                break;
            case center:
                position.x = parentW / 2f + position.x;
                break;
        }

        final switch (alignY) with (UIElement.AlignY) {
            case bottom:
                break;
            case top:
                position.y = parentH - (position.y + (size.y * scale.y));
                break;
            case center:
                position.y = parentH / 2f + position.y;
                break;
        }

        // Adjust position
        position *= 2f;

        // Set new transform
        transform = Transform2D(position, rotation, scale);

        // Prepare draw for children
        foreach (Instance2D child; children) {
            UIElement childElement = cast(UIElement) child;
            childElement.draw(renderer);
        }
    }
}
*/
