module alma.script.saudio;

import grimoire;
import magia;

import alma.script.common;

void loadAlchimieLibAudio(GrModule lib) {
    GrType vec3Type = grGetNativeType("vec3", [grFloat]);
    GrType instanceType = grGetNativeType("Instance");

    GrType soundType = lib.addNative("Sound");

    lib.addConstructor(&_sound_ctor, soundType, [grString]);
    lib.addFunction(&_sound_play, "play", [soundType]);
   /* lib.addFunction(&_sound_play2D, "play2D", [soundType, vec2Type]);
    lib.addFunction(&_sound_play3D, "play3D", [soundType, vec3Type]);
    lib.addFunction(&_sound_playOn, "play", [soundType, instanceType]);*/
}

private void _sound_ctor(GrCall call) {
    Sound sound = new Sound(Magia.res.get!Sound(call.getString(0)));
    call.setNative(sound);
}

/// @TODO
private void _sound_play(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Magia.audio.play(sound);
}

/// @TODO
/*private void _sound_play2D(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Magia.audio.play2D(sound);
}*/
/*
private void _sound_play2D_target(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Instance2D instance = call.getNative!ModelInstance(1);
    Magia.audio.play2D(sound, instance);
}*/
/*
private void _sound_play3D(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Magia.audio.play3D(sound, );
}*/
/*
private void _sound_play3D_target(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Instance3D instance = call.getNative!ModelInstance(1);
    Magia.audio.play3D(sound, instance);
}*/