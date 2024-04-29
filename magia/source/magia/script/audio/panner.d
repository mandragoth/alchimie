module magia.script.audio.panner;

import grimoire;

import magia.audio;
import magia.core;
import magia.kernel;
import magia.script.common;

package void loadLibAudio_panner(GrModule mod) {
    mod.setModule("audio.panner");
    mod.setModuleInfo(GrLocale.fr_FR, "Règle la stéréo de l’audio");

    GrType pannerType = mod.addNative("AudioPanner", [], "AudioEffect");

    mod.addConstructor(&_ctor, pannerType);

    mod.addProperty(&_panning!"get", &_panning!"set", "panning", pannerType, grFloat);
}

private void _ctor(GrCall call) {
    AudioPanner panner = new AudioPanner;
    call.setNative(panner);
}

private void _panning(string op)(GrCall call) {
    AudioPanner panner = call.getNative!AudioPanner(0);

    static if (op == "set") {
        panner.panning = call.getFloat(1);
    }

    call.setFloat(panner.panning);
}
