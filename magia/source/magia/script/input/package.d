module magia.script.input;

import grimoire;

import magia.script.input.event;
import magia.script.input.input;

package(magia.script) GrModuleLoader[] getLibLoaders_input() {
    return [
        &loadLibInput_event, //
        &loadLibInput_input //
    ];
}
