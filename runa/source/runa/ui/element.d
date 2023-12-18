module runa.ui.element;

import runa.core;
import runa.render;

/// Abstract class representing an UI element
abstract class UIElement {
    public {
        UIElement[] _children;
        Graphic[] _graphics;
    }

    private {
        bool _isHovered, _isFocused, _isPressed, _isSelected, _isActivated, _isGrabbed;
        bool _isEnabled;
    }

    /// Position
    float posX = 0f, posY = 0f;

    /// Scale
    float sizeX = 0f, sizeY = 0f;

    /// Pivot point
    float pivotX = .5f, pivotY = .5f;

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

    AlignX alignX = AlignX.center;
    AlignY alignY = AlignY.center;

    /// Transitions
    float offsetX = 0f, offsetY = 0f;
    float scaleX = 1f, scaleY = 1f;
    Color color = Color.white;
    float alpha = 1f;
    double angle = 0.0;

    static final class State {
        /// Name of state
        string name;

        /// Offset to set
        float offsetX = 0f, offsetY = 0f;

        /// Scale to set
        float scaleX = 1f, scaleY = 1f;

        /// Couleur
        Color color = Color.white;

        /// Angle to set
        float angle = 0f;

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

    // Propriétés

    @property {
        bool isHovered() const {
            return _isHovered;
        }

        bool isHovered(bool isHovered_) {
            if (_isHovered != isHovered_) {
                _isHovered = isHovered_;
                onHover();
            }
            return _isHovered;
        }

        bool isFocused() const {
            return _isFocused;
        }

        bool isFocused(bool isFocused_) {
            if (_isFocused != isFocused_) {
                _isFocused = isFocused_;
                onFocus();
            }
            return _isFocused;
        }

        bool isPressed() const {
            return _isPressed;
        }

        bool isPressed(bool isPressed_) {
            if (_isPressed != isPressed_) {
                _isPressed = isPressed_;
                onPress();
            }
            return _isPressed;
        }

        bool isSelected() const {
            return _isSelected;
        }

        bool isSelected(bool isSelected_) {
            if (_isSelected != isSelected_) {
                _isSelected = isSelected_;
                onSelect();
            }
            return _isSelected;
        }

        bool isActivated() const {
            return _isActivated;
        }

        bool isActivated(bool activated_) {
            if (_isActivated != activated_) {
                _isActivated = activated_;
                onActive();
            }
            return _isActivated;
        }

        bool isGrabbed() const {
            return _isGrabbed;
        }

        bool isGrabbed(bool isGrabbed_) {
            if (_isGrabbed != isGrabbed_) {
                _isGrabbed = isGrabbed_;
                onGrab();
            }
            return _isGrabbed;
        }

        bool isEnabled() const {
            return _isEnabled;
        }

        bool isEnabled(bool isEnabled_) {
            if (_isEnabled != isEnabled_) {
                _isEnabled = isEnabled_;
                onEnable();
            }
            return _isEnabled;
        }
    }

    bool focusable, movable;

    //GrEvent onSubmitEvent;

    bool alive = true;

    void update() {
    }

    void draw() {
    }

    void onHover() {
    }

    void onFocus() {
    }

    void onPress() {
    }

    void onSelect() {
    }

    void onActive() {
    }

    void onGrab() {
    }

    void onSubmit() {
        /*if (onSubmitEvent) {
            app.callEvent(onSubmitEvent);
        }*/
    }

    void onEnable() {
    }
}
