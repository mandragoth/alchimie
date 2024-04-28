module magia.kernel.loader.skybox;

import farfadet;
import magia.core;
import magia.render;
import magia.kernel.runtime;

/// Crée une boîte à ciel
package void compileSkybox(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string[] keys = ["right", "left", "top", "bottom", "front", "back"];

    ffd.accept(keys);
    string[] filePaths;
    foreach (key; keys) {
        filePaths ~= path ~ ffd.getNode(key, 1).get!string(0);
    }

    stream.write!string(rid);
    foreach (filePath; filePaths) {
        stream.write!string(filePath);
    }
}

package void loadSkybox(InStream stream) {
    string rid = stream.read!string();
    string[6] filePaths;

    static foreach (i; 0 .. 6) {
        filePaths[i] = stream.read!string();
    }

    Magia.res.store(rid, { return new Skybox(filePaths); });
}
