/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.cli.cli_default;

import std.stdio;

import magia.core;
import magia.kernel;

void cliDefault(Cli.Result cli) {
    if (cli.hasOption("version")) {
        log("Magia version " ~ Alchimie_Version_Display);
    }
    else if (cli.hasOption("help")) {
        if (cli.optionalParamCount() >= 1)
            log(cli.getHelp(cli.getOptionalParam(0)));
        else
            log(cli.getHelp());
    }
    else {
        log(cli.getHelp());
    }
}

void cliVersion(Cli.Result cli) {
    log("Magia version " ~ Alchimie_Version_Display);
}

void cliHelp(Cli.Result cli) {
    if (cli.optionalParamCount() >= 1)
        log(cli.getHelp(cli.getOptionalParam(0)));
    else
        log(cli.getHelp());
}
