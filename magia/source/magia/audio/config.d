/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module magia.audio.config;

enum Alchimie_Audio_SampleRate = 48_000;
enum Alchimie_Audio_FrameSize = 128;
enum Alchimie_Audio_Channels = 2;
enum Alchimie_Audio_BufferSize = Alchimie_Audio_FrameSize * Alchimie_Audio_Channels;