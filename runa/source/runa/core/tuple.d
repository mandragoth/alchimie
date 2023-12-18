module runa.core.tuple;

import std.typetuple;

/// Tuple range class
template TupleRange(int from, int to) if (from <= to) {
    static if (from >= to) {
        alias TupleRange = TypeTuple!();
    } else {
        alias TupleRange = TypeTuple!(from, TupleRange!(from + 1, to));
    }
}