module magia.script.ui;

import grimoire;
import magia.script.ui.tempui;

package(magia.script) GrModuleLoader[] getLibLoaders_ui() {
    return [
        &loadLibUI_tempui,
    ];
}
