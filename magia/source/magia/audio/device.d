module magia.audio.device;

import std.exception : enforce;

import bindbc.openal;

package {
    /// Représente le périphérique audio
    ALCdevice* _device;
}

/// Initialise le module audio
void openAudio() {
    ALSupport alSupport = loadOpenAL();
    final switch (alSupport) with (ALSupport) {
    case al11:
        break;
    case noLibrary:
        throw new Exception("[Audio] aucune bibliothèque de trouvée");
    case badLibrary:
        throw new Exception("[Audio] mauvaise bibliothèque de trouvée");
    }

    _device = alcOpenDevice(null);
    enforce(_device, "[Audio] impossible de charger le périphérique");
}

/// Ferme le module audio
void closeAudio() {
    alcCloseDevice(_device);
}
