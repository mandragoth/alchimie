module magia.core.singleton;

/** Singleton
Usage:
```d
class A {
    mixin Singleton;

    void foo() {

    }
}

void main() {
    A().foo();
}
```
*/
template Singleton() {
    private static bool _isInstantiated;
    private __gshared typeof(this) _instance;

    /// Retourne l’instance du singleton
    static typeof(this) opCall() {
        if (!_isInstantiated) {
            synchronized (typeof(this).classinfo) {
                if (!_instance) {
                    _instance = new typeof(this)();
                }
                _isInstantiated = true;
            }
        }
        return _instance;
    }
}
