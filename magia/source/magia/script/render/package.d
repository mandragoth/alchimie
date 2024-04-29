module magia.script.render;

import grimoire;
import magia.script.render.bullet;
import magia.script.render.camera;
import magia.script.render.drawable;
import magia.script.render.graphics;

package(magia.script) GrModuleLoader[] getLibLoaders_render() {
    return [
        &loadLibRender_bullet,
        &loadLibRender_camera,
        &loadLibRender_drawable,
        &loadLibRender_graphics,
    ];
}
