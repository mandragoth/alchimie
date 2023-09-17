import std.stdio;

import magia;

import alchimie.cmd_default;
import alchimie.cmd_export;
import alchimie.cmd_init;
import alchimie.cmd_run;

void main(string[] args) {
    //args = [args[0], "init", "sosis"];
	try {
        Cli cli = new Cli();
        cli.setDefault(&_cmdDefault);
        cli.addOption("v", "version");
        cli.addOption("h", "help");
        cli.addCommand(&_cmdInit, "init", 0, 1);
        cli.addCommand(&_cmdRun, "run", 0, 1);
        cli.addCommand(&_cmdExport, "export", 0, 1);
        cli.addCommand(&_cmdExport, "pack", 0, 1);
        cli.addCommand(&_cmdExport, "unpack", 0, 1);
        cli.parse(args);
    }
    catch (Exception e) {
        writeln(e.msg);
    }
}