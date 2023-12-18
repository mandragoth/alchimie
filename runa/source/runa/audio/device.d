module runa.audio.device;

import std.exception : enforce;

import std.stdio;
import std.string;

import bindbc.openal;

import runa.audio.util;

/// Représente un périphérique audio
final class AudioDevice {
    private {
        /// Représente le périphérique audio
        ALCdevice* _device;
    }

    @property {
        package ALCdevice* handle() {
            return _device;
        }
    }

    /// Init
    this(string deviceName = "") {
        _openAudio(deviceName);
    }

    /// Déinit
    ~this() {
        _closeAudio();
    }

    /// Initialise le module audio
    private void _openAudio(string deviceName) {
        ALSupport alSupport = loadOpenAL();
        final switch (alSupport) with (ALSupport) {
        case al11:
            break;
        case noLibrary:
            throw new Exception("[Audio] aucune bibliothèque de trouvée");
        case badLibrary:
            throw new Exception("[Audio] mauvaise bibliothèque de trouvée");
        }

        enforce(alcIsExtensionPresent(null, "ALC_ENUMERATION_EXT") == AL_TRUE,
            "[Audio] ALC_ENUMERATION_EXT n’est pas disponible");

        if (!deviceName.length)
            _device = alcOpenDevice(null);
        else {
            const(char)* deviceCStr = toStringz(deviceName);
            writeln("OPENING ", deviceName);
            _device = alcOpenDevice(deviceCStr);
        }

        enforce(_device, "[Audio] impossible de charger le périphérique " ~ deviceName);
        //assertAL();

        //writeln(getDevices());
    }

    /// Ferme le module audio
    private void _closeAudio() {
        alcCloseDevice(_device);
        _device = null;
    }

    string[] getDevices() {
        const(ALchar)* deviceSpecifier;
        deviceSpecifier = alcGetString(null, ALC_ALL_DEVICES_SPECIFIER);
        size_t i;
        bool wasNull;
        string[] devices;
        string currentDevice;
        for (;;) {
            if (deviceSpecifier[i] == '\0') {
                if (wasNull)
                    break;
                wasNull = true;
                devices ~= currentDevice.replace("OpenAL Soft on ", "");
                currentDevice.length = 0;
            } else {
                wasNull = false;
                currentDevice ~= deviceSpecifier[i];
            }
            i++;
        }
        return devices;
    }

    string getCurrentDevice() {
        const(ALchar)* deviceSpecifier;
        deviceSpecifier = alcGetString(null, ALC_DEFAULT_ALL_DEVICES_SPECIFIER);
        size_t i;
        string currentDevice;
        for (;;) {
            if (deviceSpecifier[i] == '\0') {
                return currentDevice.replace("OpenAL Soft on ", "");
            }
            currentDevice ~= deviceSpecifier[i];
            i++;
        }
    }
}