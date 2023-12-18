module runa.audio.util;

import bindbc.openal;

package void assertAL() {
    ALenum error = alGetError();
    switch (error) {
    case AL_NO_ERROR:
        return;
    case AL_INVALID_NAME:
        throw new Exception("AL: nom invalide");
    case AL_INVALID_ENUM:
        throw new Exception("AL: énum invalide");
    case AL_INVALID_VALUE:
        throw new Exception("AL: valeur invalide");
    case AL_INVALID_OPERATION:
        throw new Exception("AL: opération invalide");
    case AL_OUT_OF_MEMORY:
        throw new Exception("AL: mémoire manquante");
    default:
        throw new Exception("AL: erreur inconnue");
    }
}
