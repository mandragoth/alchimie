module magia.kernel.loader.texture;

import farfadet;
import magia.core;
import magia.render;
import magia.kernel.runtime;

/// Crée des textures
package void compileTexture(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["file"]);
    string filePath = ffd.getNode("file", 1).get!string(0);

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
}

package void loadTexture(InStream stream) {
    string rid = stream.read!string();
    string filePath = stream.read!string();

    Magia.res.store(rid, {
        Texture texture = new Texture(filePath, TextureType.sprite);
        Magia.res.store(rid, {
            SpritePool spritePool = new SpritePool(texture);
            return spritePool;
        });
        return texture;
    });
}
