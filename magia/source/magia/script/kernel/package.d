module magia.script.kernel;

import grimoire;
import magia.script.kernel.runtime;

package(magia.script) GrModuleLoader[] getLibLoaders_kernel() {
    return [
        &loadLibCore_runtime,
    ];
}
