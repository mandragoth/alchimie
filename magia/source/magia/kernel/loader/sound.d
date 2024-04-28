module magia.kernel.loader.sound;

import farfadet;
import magia.core;
import magia.audio;
import magia.kernel.runtime;

/// Crée un son
package void compileSound(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["file", "volume"]);
    string filePath = ffd.getNode("file", 1).get!string(0);

    float volume = 1f;
    if (ffd.hasNode("volume")) {
        volume = ffd.getNode("volume", 1).get!float(0);
    }

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
    stream.write!float(volume);
}

package void loadSound(InStream stream) {
    string rid = stream.read!string();
    string file = stream.read!string();
    float volume = stream.read!float();

    Magia.res.store(rid, {
        Sound sound = Sound.fromResource(file);
        sound.volume = volume;
        return sound;
    });
}
