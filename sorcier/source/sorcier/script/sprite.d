module sorcier.script.sprite;

import grimoire;

import magia.core, magia.render;

void loadMagiaLibSprite(GrLibrary library) {
    /+GrType spriteType = library.addNative("Sprite", [], "Drawable");
    GrType textureType = grGetNativeType("Texture");

    library.addFunction(&_sprite1, "Sprite", [textureType], [spriteType]);
    library.addFunction(&_sprite2, "Sprite", [
            textureType, grInt, grInt, grInt, grInt
        ], [spriteType]);

    library.addFunction(&_setClip, "setClip", [
            spriteType, grInt, grInt, grInt, grInt
        ]);
    library.addFunction(&_getClip, "getClip", [], [
            spriteType, grInt, grInt, grInt, grInt
        ]);

    library.addFunction(&_getWidth, "getWidth", [spriteType], [grFloat]);
    library.addFunction(&_getHeight, "getHeight", [spriteType], [grFloat]);
    library.addFunction(&_getHeight, "getSize", [spriteType], [grFloat, grFloat]);+/
}
/+
private void _sprite1(GrCall call) {
    Sprite sprite = new Sprite(call.getNative!Texture(0));
    call.setNative(sprite);
}

private void _sprite2(GrCall call) {
    Sprite sprite = new Sprite(call.getNative!Texture(0),
        Vec4i(call.getInt(1), call.getInt(2), call.getInt(3), call.getInt(4)));
    call.setNative(sprite);
}

private void _setClip(GrCall call) {
    Sprite sprite = call.getNative!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    sprite.clip = Vec4i(call.getInt(1), call.getInt(2), call.getInt(3), call.getInt(4));
}

private void _getClip(GrCall call) {
    Sprite sprite = call.getNative!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }

    call.setInt(sprite.clip.x);
    call.setInt(sprite.clip.y);
    call.setInt(sprite.clip.z);
    call.setInt(sprite.clip.w);
}

private void _getWidth(GrCall call) {
    Sprite sprite = call.getNative!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    call.setFloat(sprite.size.x);
}

private void _getHeight(GrCall call) {
    Sprite sprite = call.getNative!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    call.setFloat(sprite.size.y);
}

private void _getSize(GrCall call) {
    Sprite sprite = call.getNative!Sprite(0);
    if (!sprite) {
        call.raise("NullError");
        return;
    }
    call.setFloat(sprite.size.x);
    call.setFloat(sprite.size.y);
}
+/