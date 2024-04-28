module magia.kernel.loader.diffuse;

import farfadet;
import magia.core;
import magia.render;
import magia.kernel.runtime;

/// Crée des diffuses
package void compileDiffuse(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["file"]);
    string filePath = ffd.getNode("file", 1).get!string(0);

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
}

package void loadDiffuse(InStream stream) {
    string rid = stream.read!string();
    string filePath = stream.read!string();

    Magia.res.store(rid, { return new Texture(filePath, TextureType.diffuse); });
}
