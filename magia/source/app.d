import std.stdio;
import grimoire;

import magia.cli;
import magia.kernel;
import magia.doc : generateDoc;

version (MagiaDLL) {
    version (Windows) {
        import core.sys.windows.dll;

        mixin SimpleDllMain;
    }

    export extern (D) void startupDev(string[] args) {
        try {
            openLogger(false);
            parseCli(args);
        }
        catch (GrCompilerException e) {
            log(e.msg);
        }
        catch (Exception e) {
            log("Erreur: ", e.msg);
        }
        finally {
            closeLogger();
        }
    }

    export extern (D) void startupRedist(string[] args) {
        try {
            openLogger(true);
            boot(args);
        }
        catch (Exception e) {
            log("Erreur: ", e.msg);
        }
        finally {
            closeLogger();
        }
    }
}
else version (MagiaExe) {
    extern (C) __gshared string[] rt_options = [
        "gcopt=initReserve:128 minPoolSize:256 parallel:2"
    ];

    void main(string[] args) {
        openLogger(false);

        version (MagiaDebug) {
            args = args[0] ~ ["run", "../test"];
        }

        try {
            version (MagiaDoc) {
                generateDoc();
            }
            else version (MagiaDebug) {
                parseCli(args);
            }
        }
        catch (GrCompilerException e) {
            log(e.msg);
        }
        catch (Exception e) {
            log("Erreur: ", e.msg);
            version (MagiaDebug) {
                foreach (trace; e.info) {
                    log("à: ", trace);
                }
            }
        }
        finally {
            closeLogger();
        }
    }
}
