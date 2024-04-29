module magia.script.audio.bus;

import grimoire;

import magia.audio;
import magia.core;
import magia.kernel;
import magia.script.common;

package void loadLibAudio_bus(GrModule mod) {
    mod.setModule("audio.bus");
    mod.setModuleInfo(GrLocale.fr_FR, "Route les sons et leur applique des effets");

    GrType busType = mod.addNative("AudioBus");

    GrType playerType = grGetNativeType("AudioPlayer");
    GrType soundType = grGetNativeType("Sound");
    GrType musicType = grGetNativeType("Music");
    GrType effectType = grGetNativeType("AudioEffect");

    mod.addConstructor(&_ctor, busType);

    mod.setDescription(GrLocale.fr_FR, "Coupe le son du bus");
    mod.addProperty(&_isMuted!"get", &_isMuted!"set", "isMuted", busType, grBool);

    mod.setDescription(GrLocale.fr_FR, "Joue le son sur le bus.");
    mod.setParameters(["bus", "player"]);
    mod.addFunction(&_play, "play", [busType, playerType]);
    mod.addFunction(&_playSound, "play", [busType, soundType]);
    mod.addFunction(&_playMusic, "play", [busType, musicType]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un effet.");
    mod.setParameters(["bus", "effect"]);
    mod.addFunction(&_addEffect, "addEffect", [busType, effectType]);

    mod.setDescription(GrLocale.fr_FR, "Connecte le bus à un bus destinataire.");
    mod.setParameters(["srcBus", "destBus"]);
    mod.addFunction(&_connectTo, "connectTo", [busType, busType]);

    mod.setDescription(GrLocale.fr_FR, "Connecte le bus au bus maître.");
    mod.setParameters(["bus"]);
    mod.addFunction(&_connectToMaster, "connectToMaster", [busType]);

    mod.setDescription(GrLocale.fr_FR, "Déconnecte le bus de toute destination.");
    mod.setParameters(["srcBus", "destBus"]);
    mod.addFunction(&_disconnect, "disconnect", [busType]);
}

private void _ctor(GrCall call) {
    AudioBus bus = new AudioBus();
    bus.connectToMaster();
    call.setNative(bus);
}

private void _isMuted(string op)(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);

    static if (op == "set") {
        bus.isMuted = call.getBool(1);
    }

    call.setBool(bus.isMuted);
}

private void _play(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    AudioPlayer player = call.getNative!AudioPlayer(1);
    bus.play(player);
}

private void _playSound(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    Sound sound = call.getNative!Sound(1);
    bus.play(new SoundPlayer(sound));
}

private void _playMusic(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    Music music = call.getNative!Music(1);
    bus.play(new MusicPlayer(music));
}

private void _addEffect(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    AudioEffect effect = call.getNative!AudioEffect(1);
    bus.addEffect(effect);
}

private void _connectTo(GrCall call) {
    AudioBus bus1 = call.getNative!AudioBus(0);
    AudioBus bus2 = call.getNative!AudioBus(1);
    bus1.connectTo(bus2);
}

private void _connectToMaster(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    bus.connectToMaster();
}

private void _disconnect(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    bus.disconnect();
}
