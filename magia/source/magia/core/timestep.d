module magia.core.timestep;

struct TimeStep {
    private {
        float _time;
    }

    @property {
        float time() const {
            return _time;
        }
    }

    this(float time) {
        _time = time;
    }
}