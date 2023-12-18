/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module runa.ui.button;

import runa.ui.element;

import runa.core;
import runa.kernel;
import runa.render;
import runa.ui.label;

final class RippleEffect {
    private {
        class Ripple {
            Timer timer;
            float startRadius, radius;
            float startAlpha, alpha;
            float x, y;
        }

        Circle _circle;

        Array!Ripple _ripples;

        float _x, _y;
        float _radius = 10f;

        Ripple _pressedRipple;
        bool _isPressed;
    }

    Color color;

    this(float radius_) {
        _radius = radius_ * 2f;
        _ripples = new Array!Ripple;

        _circle = new Circle(_radius, true, 0f);
        _circle.blend = Blend.alpha;
        _circle.noCache = true;
        _circle.cache();
    }

    void onPress(bool isPressed_) {
        if (isPressed_) {
            _isPressed = true;
            _pressedRipple = new Ripple;
            _pressedRipple.startRadius = _pressedRipple.radius = 10f;
            _pressedRipple.startAlpha = _pressedRipple.alpha = .26f;
            _pressedRipple.x = Runa.ui.pressedX;
            _pressedRipple.y = Runa.ui.pressedY;
            _pressedRipple.timer.start(30);
        }
        else {
            if (!_isPressed)
                return;
            _isPressed = false;

            _pressedRipple.timer.start(20);
            _pressedRipple.startRadius = _pressedRipple.radius;
            _pressedRipple.startAlpha = _pressedRipple.alpha;

            if (_ripples.full) {
                size_t index;
                int timer = 0;
                foreach (i, ripple; _ripples) {
                    if (!ripple.timer.isRunning) {
                        index = i;
                        break;
                    }
                    if (ripple.timer.value > timer) {
                        timer = ripple.timer.value;
                        index = i;
                    }
                }
                _ripples[index] = _pressedRipple;
            }
            else {
                _ripples.push(_pressedRipple);
            }
        }
    }

    void update() {
        foreach (i, ripple; _ripples) {
            ripple.timer.update();
            if (!ripple.timer.isRunning) {
                _ripples.mark(i);
            }
            else {
                ripple.radius = lerp(ripple.startRadius, _radius,
                    easeOutQuad(ripple.timer.value01));
                ripple.alpha = lerp(ripple.startAlpha, 0f, easeOutSine(ripple.timer.value01));
            }
        }
        _ripples.sweep();

        if (_isPressed) {
            _pressedRipple.timer.update();

            _pressedRipple.x = Runa.ui.pressedX;
            _pressedRipple.y = Runa.ui.pressedY;

            _pressedRipple.radius = lerp(_pressedRipple.startRadius, _radius,
                easeOutSine(_pressedRipple.timer.value01));
            /*_pressedRipple.alpha = lerp(_pressedRipple.startAlpha, 0.2f,
                easeOutSine(_pressedRipple.timer.value01));*/
        }
    }

    void draw() {
        _circle.color = color;

        foreach (ripple; _ripples) {
            _circle.radius = ripple.radius;
            _circle.alpha = ripple.alpha;
            _circle.draw(ripple.x, ripple.y);
        }

        if (_isPressed) {
            _circle.radius = _pressedRipple.radius;
            _circle.alpha = _pressedRipple.alpha;
            _circle.draw(_pressedRipple.x, _pressedRipple.y);
        }
    }
}

final class ButtonFx {
    private {
        UIElement _ui;
        float _alpha = 0f, _targetAlpha = 0f;
        RoundedRectangle _background, _mask;
        RippleEffect _rippleEffect;
    }

    Color color;

    this(UIElement ui) {
        _ui = ui;
        _background = new RoundedRectangle(_ui.sizeX, _ui.sizeY, 8f, true, 0f);
        _background.anchorX = 0f;
        _background.anchorY = 0f;

        _mask = new RoundedRectangle(_ui.sizeX, _ui.sizeY, 8f, true, 0f);
        _mask.anchorX = 0f;
        _mask.anchorY = 0f;
        _mask.blend = Blend.mask;

        _rippleEffect = new RippleEffect(_ui.sizeX);
    }

    void update() {
        _targetAlpha = 0f;

        if (!_ui.isEnabled) {
            _alpha = 0f;
            return;
        }

        if (_ui.isGrabbed) {
            _targetAlpha += 0.16f * 5f;
        }
        else if (_ui.isPressed || _ui.isFocused) {
            _targetAlpha += 0.12f * 5f;
        }
        else if (_ui.isHovered) {
            _targetAlpha += 0.08f * 5f;
        }

        _alpha = approach(_alpha, _targetAlpha, .1f);

        _rippleEffect.update();
    }

    void draw() {
        _background.blend = Blend.alpha;
        _background.color = color;
        _background.alpha = _alpha;
        _background.draw(0f, 0f);

        Runa.renderer.pushCanvas(cast(int) _ui.sizeX, cast(int) _ui.sizeY);

        _rippleEffect.color = Color.fromHex(0xff0000);
        _rippleEffect.draw();
        _background.blend = Blend.mask;
        _background.color = Color.white;
        _background.alpha = 1f;
        _background.draw(0f, 0f);

        Runa.renderer.popCanvas(0f, 0f, _ui.sizeX, _ui.sizeY, 0f, 0f, 0f, color, 1f);
    }

    void onPress(bool pressed) {
        _rippleEffect.onPress(pressed);
    }
}

Color color_primary = Color.fromHex(0x6750A4);
Color color_outline = Color.fromHex(0x79747E);
Color color_onPrimary = Color.fromHex(0xFFFFFF);
Color color_onSurface = Color.fromHex(0x1C1B1F);

final class FilledButton : UIElement {
    private {
        RoundedRectangle _background;
        ButtonFx _fx;
        Label _text;
    }

    this(string text_) {
        _text = new Label(text_);
        _children ~= _text;

        sizeX = _text.sizeX + 48f;
        sizeY = 40f;

        _fx = new ButtonFx(this);

        _background = new RoundedRectangle(sizeX, sizeY, 8f, true, 0f);
        _graphics ~= _background;

        isEnabled = true;
    }

    override void onEnable() {
        if (isEnabled) {
            _background.color = color_primary;
            _text.color = color_onPrimary;
            _fx.color = color_onPrimary;

            _background.alpha = 1f;
            _text.alpha = 1f;
        }
        else {
            _background.color = color_onSurface;
            _text.color = color_onSurface;

            _background.alpha = 0.12f;
            _text.alpha = 0.38f;
        }
    }

    override void onPress() {
        _fx.onPress(isPressed);
    }

    override void update() {
        _fx.update();
    }

    override void draw() {
        _fx.draw();
    }
}

final class OutlinedButton : UIElement {
    private {
        RoundedRectangle _background;
        ButtonFx _fx;
        Label _text;
    }

    this(string text_) {
        _text = new Label(text_);
        _children ~= _text;

        sizeX = _text.sizeX + 48f;
        sizeY = 40f;

        _fx = new ButtonFx(this);

        _background = new RoundedRectangle(sizeX, sizeY, 8f, false, 1f);
        _graphics ~= _background;

        isEnabled = true;
    }

    override void onEnable() {
        if (isEnabled) {
            _background.color = color_outline;
            _text.color = color_primary;
            _fx.color = color_primary;

            _background.alpha = 1f;
            _text.alpha = 1f;
        }
        else {
            _background.color = color_onSurface;
            _text.color = color_onSurface;

            _background.alpha = 0.12f;
            _text.alpha = 0.38f;
        }
    }

    override void onPress() {
        _fx.onPress(isPressed);
    }

    override void update() {
        _fx.update();
    }

    override void draw() {
        _fx.draw();
    }
}

final class TextButton : UIElement {
    private {
        ButtonFx _fx;
        Label _text;
    }

    this(string text_) {
        _text = new Label(text_);
        _children ~= _text;

        sizeX = _text.sizeX + 48f;
        sizeY = 40f;

        _fx = new ButtonFx(this);

        isEnabled = true;
    }

    override void onEnable() {
        if (isEnabled) {
            _text.color = color_primary;
            _fx.color = color_primary;

            _text.alpha = 1f;
        }
        else {
            _text.color = color_onSurface;

            _text.alpha = 0.38f;
        }
    }

    override void onPress() {
        _fx.onPress(isPressed);
    }

    override void update() {
        _fx.update();
    }

    override void draw() {
        _fx.draw();
    }
}
