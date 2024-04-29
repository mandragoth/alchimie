module magia.script.core;

import grimoire;
import magia.script.core.color;
import magia.script.core.hslcolor;
import magia.script.core.math;
import magia.script.core.spline;
import magia.script.core.vec;

package(magia.script) GrModuleLoader[] getLibLoaders_core() {
    return [
        &loadLibCore_color,
        &loadLibCore_hslcolor,
        &loadLibCore_math,
        &loadLibCore_spline,
        &loadLibCore_vec,
    ];
}
