# Grimoire

Grimoire is a simple and fast concurrent programming language that can easily be embedded into another D programs.
You can very easily interface your program with Grimoire's scripts.

Hope you have fun with this project !

[Documentation here !](https://enalye.github.io/grimoire)

What it looks like:

```cpp
//Hello World
event main() {
    "Hello World!":print;
}
```

```go
//Invert a string
event main() {
    assert("Hello World !".invert == "! dlroW olleH");
}

func invert(str: string) (string) {
    let result = str as<list<string>>;
    loop(i, result.size / 2)
        result[i], result[-(i + 1)] = result[-(i + 1)], result[i];
    return result as<string>;
}
```

```go
//Fibonacci
event fib() {
    assert(
        function(int n) (int) {
            if(n < 2) return n;
            return self(n - 1) + self(n - 2);
        }(10) == 55);
}
```

## Install

Use `dub` to include grimoire in your project (or just dump the files in your project if you want).
Open the "test" folder to see how to add Grimoire to your program or copy/paste it.

Grimoire is in 2 parts:

- The compiler
- The runtime

### Compilation

To bind functions defined in D and add other types, you can create a `GrLibrary` which will store primitives and type information. The `GrLibrary` object can be shared between multiple compilations.

To compile, you need a compiler `GrCompiler` which will turn your scripts into bytecode with `compileFile`.

You must add the `GrLibrary` objects to the compiler before calling `compileFile` witch `addLibrary`.
If the compilation fails, you can fetch the error with `getError()`.

If it's successful, the `compileFile` function will returns a `GrBytecode` that stores the bytecode generated by the compiler, which can be saved into a file or run by the VM.

```d
// Some basic functions are provided by the default library.
GrLibrary stdlib = grLoadStdLibrary(); 

GrCompiler compiler = new GrCompiler;

// We add the default library.
compiler.addLibrary(stdlib);

// We compile the file.
GrBytecode bytecode = compiler.compileFile("test.gr");

if(bytecode) {
    // Compilation successful
}
else {
    // Error while compiling
    import std.stdio: writeln;
    writeln(compiler.getError().prettify());
}
```

### Debug & Profiling

You can see the generated bytecode with

```d
grDump(bytecode);
```

Which formats the bytecode in a printable way.

Grimoire also provide a basic profiling tool, to use it, to need to specify a flag during compilation to activate debug informations.

```d
compiler.compileFile("test.gr", GrCompiler.Flags.profile);
```

The profiling information are accessible on the GrEngine with:

```d
engine.dumpProfiling();
```

An already formatted version is accessible with:

```d
engine.prettifyProfiling();
```

### Processing

Then, create the runtime's virtual machine `GrEngine`, you'll first need to add the same libraries as the compiler and in the same order.
Then, load the bytecode.

```d
GrEngine engine = new GrEngine;
engine.addLibrary(stdlib);
engine.load(bytecode);
```

You can then spawn any event like this:

```d
auto mangledName = grMangleComposite("myEvent", [grString]);
if(engine.hasEvent(mangledName)) {
    GrTask task = engine.callEvent(mangledName);
    task.setString("Hello World!");
}
```

But be aware that every function/task/event are mangled with their signature, so use `grMangleComposite` to generate the  correct function's name.

If the event has parameters, you must push them into the context with the `setXX` functions.

To run the virtual machine, just call the process function (and check if there's any task(Coroutine) currently running):

```d
while(engine.hasTasks)
    engine.process();
```

The program will run until all tasks are finished, if you want them to run only for one step, replace the `while` with `if`.

You can then check if there are any unhandled errors that went through the VM (Caught exceptions won't trigger that).

```d
if(engine.isPanicking)
    writeln("unhandled exception: " ~ engine.panicMessage);
```

## Documentation

You can find the language documentation [&gt; here ! &lt;](https://enalye.github.io/grimoire)
