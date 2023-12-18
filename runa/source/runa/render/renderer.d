module runa.render.renderer;

import std.exception : enforce;

import bindbc.sdl;

import runa.core;
import runa.render.canvas;
import runa.render.window;

final class Renderer {
    private {
        final class CanvasContext {
            Canvas canvas;
            vec4i clip;
        }

        SDL_Renderer* _target;
        CanvasContext[] _canvases;
        int _idxContext = -1;
    }

    @property {
        SDL_Renderer* target() {
            return _target;
        }
    }

    Color color = Color.white;

    this(Window window) {
        _target = SDL_CreateRenderer(window.target, -1,
            SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
        enforce(_target, "renderer creation failure");
    }

    void close() {
        SDL_DestroyRenderer(_target);
    }

    void render() {
        SDL_Color sdlColor = color.toSDL();

        SDL_RenderPresent(_target);
        SDL_SetRenderDrawColor(_target, sdlColor.r, sdlColor.g, sdlColor.b, 0);
        SDL_RenderClear(_target);
    }

    void pushCanvas(uint width, uint height) {
        CanvasContext context;
        _idxContext++;

        enforce(_idxContext < 128, "canvas stack limit");

        if (_idxContext == _canvases.length) {
            context = new CanvasContext;
            context.canvas = new Canvas(width, height);
            context.clip = vec4i(0, 0, width, height);
            _canvases ~= context;
        } else {
            context = _canvases[_idxContext];
            context.clip = vec4i(0, 0, width, height);

            if (context.canvas.width < width || context.canvas.height < height) {
                context.canvas.setSize(max(context.canvas.width, width),
                    max(context.canvas.height, height));
            }
        }

        SDL_Color sdlColor = context.canvas.color.toSDL();

        SDL_SetRenderTarget(_target, context.canvas.target);
        SDL_SetRenderDrawColor(_target, sdlColor.r, sdlColor.g, sdlColor.b, 0);
        SDL_RenderClear(_target);
    }

    void popCanvas(float x, float y, float w, float h, float pivotX, float pivotY,
        float angle, Color color, float alpha) {
        if (_idxContext < 0)
            return;

        CanvasContext context = _canvases[_idxContext];

        _idxContext--;
        if (_idxContext >= 0)
            SDL_SetRenderTarget(_target, _canvases[_idxContext].canvas.target);
        else
            SDL_SetRenderTarget(_target, null);

        context.canvas.color = color;
        context.canvas.alpha = alpha;
        context.canvas.draw(x, y, w, h, context.clip, pivotX, pivotY, angle);
    }

    void drawRect(float x, float y, float w, float h, Color color, float alpha, bool filled) {
        const auto sdlColor = color.toSDL();
        SDL_SetRenderDrawColor(_target, sdlColor.r, sdlColor.g, sdlColor.b,
            cast(ubyte)(clamp(alpha, 0f, 1f) * 255f));

        const SDL_FRect rect = {x, y, w, h};

        if (filled)
            SDL_RenderFillRectF(_target, &rect);
        else
            SDL_RenderDrawRectF(_target, &rect);
    }
}
