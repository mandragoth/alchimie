module magia.audio.audiomanager;

import std.exception : enforce;

import bindbc.sdl;

/// Module audio
final class AudioManager {
    private {
    }

    /// Init
    this() {
        enforce(Mix_OpenAudio(44_100, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS,
                1024) != -1, "no audio device connected");
        enforce(Mix_AllocateChannels(16) != -1, "audio channels allocation failure");
    }

    ~this() {
    }
}
