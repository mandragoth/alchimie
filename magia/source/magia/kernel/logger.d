module magia.kernel.logger;

import std.concurrency;
import std.conv : to;
import std.exception : enforce;
import std.file : append, exists, remove;
import core.vararg;
import std.stdio : stderr, write;

private {
    enum Log_Size = 1024;
    enum Log_File = "log.txt";
    Tid _loggerTid;
    bool _isInit, _isRedist;
}

void openLogger(bool isRedist) {
    if (_isInit)
        return;
    _isRedist = isRedist;
    _isInit = true;

    if (_isRedist) {
        if (exists(Log_File)) {
            remove(Log_File);
        }
        _loggerTid = spawn(&_fileLogger);
    }
    else {
        version (Windows) {
            import core.sys.windows.windows : SetConsoleOutputCP;

            SetConsoleOutputCP(65_001);
        }
        _loggerTid = spawnLinked(&_cmdLogger);
    }
    setMaxMailboxSize(_loggerTid, Log_Size, OnCrowding.ignore);
}

private struct LoggerTermination {
    Tid tid;
}

void closeLogger() {
    _loggerTid.send(LoggerTermination(thisTid()));
    enforce(receiveOnly!Tid == _loggerTid);
    if (!_isRedist) {
        stderr.flush();
    }
}

void log(T...)(T args) {
    string msg;
    static foreach (arg; args) {
        msg ~= to!string(arg);
    }
    msg ~= "\n";
    _loggerTid.send(msg);
}

private void _cmdLogger() {
    for (bool isRunning = true; isRunning;) {
        receive((string msg) { //
            stderr.write(msg);
        }, (LoggerTermination e) { //
            e.tid.send(thisTid());
        }, (LinkTerminated e) { //
            isRunning = false;
        }, (OwnerTerminated e) { //
            isRunning = false;
        });
    }
}

private void _fileLogger() {
    for (bool isRunning = true; isRunning;) {
        receive((string msg) { //
            append(Log_File, msg);
        }, (LoggerTermination e) { //
            e.tid.send(thisTid());
        }, (LinkTerminated e) { //
            isRunning = false;
        }, (OwnerTerminated e) { //
            isRunning = false;
        });
    }
}
