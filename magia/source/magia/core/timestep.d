module magia.core.timestep;

/// Timestep API
struct TimeStep {
    private {
        float _time;
    }

    @property {
        /// Get time for current frame
        float delta() const {
            return _time;
        }
    }

    /// Constructor
    this(float time) {
        _time = time;
    }
}