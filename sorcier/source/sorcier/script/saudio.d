module sorcier.script.saudio;

import grimoire;
import magia;

import sorcier.script.common;

void loadAlchimieLibAudio(GrLibDefinition lib) {
    GrType vec3Type = grGetNativeType("vec3", [grFloat]);
    GrType instanceType = grGetNativeType("Instance");

    GrType soundType = lib.addNative("Sound");

    lib.addConstructor(&_sound_ctor, soundType, [grString]);
    lib.addFunction(&_sound_play, "play", [soundType]);
    lib.addFunction(&_sound_playAt, "play", [soundType, vec3Type]);
    lib.addFunction(&_sound_playOn, "play", [soundType, instanceType]);
}

private void _sound_ctor(GrCall call) {
    Sound sound = new Sound(call.getString(0));
    call.setNative(sound);
}

private void _sound_play(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    //sound.play();
}

private void _sound_playAt(GrCall call) {
    Sound sound = call.getNative!Sound(0);
}

private void _sound_playOn(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Instance instance = call.getNative!ModelInstance(1);
    sound.play(instance.transform.position);
}