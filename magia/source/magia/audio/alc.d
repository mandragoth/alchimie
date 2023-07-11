module magia.audio.alc;

extern (C):

/** Deprecated macro. */
enum ALC_INVALID = 0;

/** Supported ALC version? */
enum ALC_VERSION_0_1 = 1;

/** Opaque device handle */
private struct ALCdevice_struct;
private alias ALCdevice = ALCdevice_struct;
/** Opaque context handle */
private struct ALCcontext_struct;
private alias ALCcontext = ALCcontext_struct;

/** 8-bit boolean */
alias ALCboolean = char;

/** character */
alias ALCchar = char;

/** signed 8-bit 2's complement integer */
alias ALCbyte = byte;

/** unsigned 8-bit integer */
alias ALCubyte = ubyte;

/** signed 16-bit 2's complement integer */
alias ALCshort = short;

/** unsigned 16-bit integer */
alias ALCushort = ushort;

/** signed 32-bit 2's complement integer */
alias ALCint = int;

/** unsigned 32-bit integer */
alias ALCuint = uint;

/** non-negative 32-bit binary integer size */
alias ALCsizei = int;

/** enumerated 32-bit value */
alias ALCenum = int;

/** 32-bit IEEE754 floating-point */
alias ALCfloat = float;

/** 64-bit IEEE754 floating-point */
alias ALCdouble = double;

/** void type (for opaque pointers only) */
alias ALCvoid = void;

/* Enumerant values begin at column 50. No tabs. */

/** Boolean False. */
enum ALC_FALSE = 0;

/** Boolean True. */
enum ALC_TRUE = 1;

/** Context attribute: <int> Hz. */
enum ALC_FREQUENCY = 0x1007;

/** Context attribute: <int> Hz. */
enum ALC_REFRESH = 0x1008;

/** Context attribute: AL_TRUE or AL_FALSE. */
enum ALC_SYNC = 0x1009;

/** Context attribute: <int> requested Mono (3D) Sources. */
enum ALC_MONO_SOURCES = 0x1010;

/** Context attribute: <int> requested Stereo Sources. */
enum ALC_STEREO_SOURCES = 0x1011;

/** No error. */
enum ALC_NO_ERROR = 0;

/** Invalid device handle. */
enum ALC_INVALID_DEVICE = 0xA001;

/** Invalid context handle. */
enum ALC_INVALID_CONTEXT = 0xA002;

/** Invalid enum parameter passed to an ALC call. */
enum ALC_INVALID_ENUM = 0xA003;

/** Invalid value parameter passed to an ALC call. */
enum ALC_INVALID_VALUE = 0xA004;

/** Out of memory. */
enum ALC_OUT_OF_MEMORY = 0xA005;

/** Runtime ALC version. */
enum ALC_MAJOR_VERSION = 0x1000;
enum ALC_MINOR_VERSION = 0x1001;

/** Context attribute list properties. */
enum ALC_ATTRIBUTES_SIZE = 0x1002;
enum ALC_ALL_ATTRIBUTES = 0x1003;

/** String for the default device specifier. */
enum ALC_DEFAULT_DEVICE_SPECIFIER = 0x1004;
/**
 * String for the given device's specifier.
 *
 * If device handle is NULL, it is instead a null-char separated list of
 * strings of known device specifiers (list ends with an empty string).
 */
enum ALC_DEVICE_SPECIFIER = 0x1005;
/** String for space-separated list of ALC extensions. */
enum ALC_EXTENSIONS = 0x1006;

/** Capture extension */
enum ALC_EXT_CAPTURE = 1;
/**
 * String for the given capture device's specifier.
 *
 * If device handle is NULL, it is instead a null-char separated list of
 * strings of known capture device specifiers (list ends with an empty string).
 */
enum ALC_CAPTURE_DEVICE_SPECIFIER = 0x310;
/** String for the default capture device specifier. */
enum ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER = 0x311;
/** Number of sample frames available for capture. */
enum ALC_CAPTURE_SAMPLES = 0x312;

/** Enumerate All extension */
enum ALC_ENUMERATE_ALL_EXT = 1;
/** String for the default extended device specifier. */
enum ALC_DEFAULT_ALL_DEVICES_SPECIFIER = 0x1012;
/**
 * String for the given extended device's specifier.
 *
 * If device handle is NULL, it is instead a null-char separated list of
 * strings of known extended device specifiers (list ends with an empty string).
 */
enum ALC_ALL_DEVICES_SPECIFIER = 0x1013;

/** Context management. */
/*ALCcontext* alcCreateContext (ALCdevice* device, const(ALCint)* attrlist);
ALCboolean alcMakeContextCurrent (ALCcontext* context);
void alcProcessContext (ALCcontext* context);
void alcSuspendContext (ALCcontext* context);
void alcDestroyContext (ALCcontext* context);
ALCcontext* alcGetCurrentContext ();
ALCdevice* alcGetContextsDevice (ALCcontext* context);*/

/** Device management. *//*
ALCdevice* alcOpenDevice (const(ALCchar)* devicename);
ALCboolean alcCloseDevice (ALCdevice* device);*/

/**
 * Error support.
 *
 * Obtain the most recent Device error.
 */
ALCenum alcGetError (ALCdevice* device);

/**
 * Extension support.
 *
 * Query for the presence of an extension, and obtain any appropriate
 * function pointers and enum values.
 */
ALCboolean alcIsExtensionPresent (ALCdevice* device, const(ALCchar)* extname);
void* alcGetProcAddress (ALCdevice* device, const(ALCchar)* funcname);
ALCenum alcGetEnumValue (ALCdevice* device, const(ALCchar)* enumname);

/** Query function. */
const(ALCchar)* alcGetString (ALCdevice* device, ALCenum param);
void alcGetIntegerv (ALCdevice* device, ALCenum param, ALCsizei size, ALCint* values);

/** Capture function. */
ALCdevice* alcCaptureOpenDevice (const(ALCchar)* devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize);
ALCboolean alcCaptureCloseDevice (ALCdevice* device);
void alcCaptureStart (ALCdevice* device);
void alcCaptureStop (ALCdevice* device);
void alcCaptureSamples (ALCdevice* device, ALCvoid* buffer, ALCsizei samples);

/** Pointer-to-function type, useful for dynamically getting ALC entry points. */
alias LPALCCREATECONTEXT = ALCcontext_struct* function (ALCdevice* device, const(ALCint)* attrlist);
alias LPALCMAKECONTEXTCURRENT = char function (ALCcontext* context);
alias LPALCPROCESSCONTEXT = void function (ALCcontext* context);
alias LPALCSUSPENDCONTEXT = void function (ALCcontext* context);
alias LPALCDESTROYCONTEXT = void function (ALCcontext* context);
alias LPALCGETCURRENTCONTEXT = ALCcontext_struct* function ();
alias LPALCGETCONTEXTSDEVICE = ALCdevice_struct* function (ALCcontext* context);
alias LPALCOPENDEVICE = ALCdevice_struct* function (const(ALCchar)* devicename);
alias LPALCCLOSEDEVICE = char function (ALCdevice* device);
alias LPALCGETERROR = int function (ALCdevice* device);
alias LPALCISEXTENSIONPRESENT = char function (ALCdevice* device, const(ALCchar)* extname);
alias LPALCGETPROCADDRESS = void* function (ALCdevice* device, const(ALCchar)* funcname);
alias LPALCGETENUMVALUE = int function (ALCdevice* device, const(ALCchar)* enumname);
alias LPALCGETSTRING = const(char)* function (ALCdevice* device, ALCenum param);
alias LPALCGETINTEGERV = void function (ALCdevice* device, ALCenum param, ALCsizei size, ALCint* values);
alias LPALCCAPTUREOPENDEVICE = ALCdevice_struct* function (const(ALCchar)* devicename, ALCuint frequency, ALCenum format, ALCsizei buffersize);
alias LPALCCAPTURECLOSEDEVICE = char function (ALCdevice* device);
alias LPALCCAPTURESTART = void function (ALCdevice* device);
alias LPALCCAPTURESTOP = void function (ALCdevice* device);
alias LPALCCAPTURESAMPLES = void function (ALCdevice* device, ALCvoid* buffer, ALCsizei samples);

enum ALC_EXT_TRACE_INFO = 1;
alias LPALCTRACEDEVICELABEL = void function (ALCdevice* device, const(ALCchar)* str);
alias LPALCTRACECONTEXTLABEL = void function (ALCcontext* ctx, const(ALCchar)* str);

/* AL_ALC_H */
