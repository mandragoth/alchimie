module magia.input.inputevent;

import std.array : join;
import std.conv : to;

import bindbc.sdl;

import magia.core;

/// Événement utilisateur
final class InputEvent {
    /// Type d’événement
    enum Type {
        none,
        keyButton,
        mouseButton,
        mouseMotion,
        mouseWheel,
        textInput,
        dropFile
    }

    /// Touche du clavier
    final class KeyButton {
        /// Touches du clavier
        enum Button {
            unknown = SDL_SCANCODE_UNKNOWN,
            a = SDL_SCANCODE_A,
            b = SDL_SCANCODE_B,
            c = SDL_SCANCODE_C,
            d = SDL_SCANCODE_D,
            e = SDL_SCANCODE_E,
            f = SDL_SCANCODE_F,
            g = SDL_SCANCODE_G,
            h = SDL_SCANCODE_H,
            i = SDL_SCANCODE_I,
            j = SDL_SCANCODE_J,
            k = SDL_SCANCODE_K,
            l = SDL_SCANCODE_L,
            m = SDL_SCANCODE_M,
            n = SDL_SCANCODE_N,
            o = SDL_SCANCODE_O,
            p = SDL_SCANCODE_P,
            q = SDL_SCANCODE_Q,
            r = SDL_SCANCODE_R,
            s = SDL_SCANCODE_S,
            t = SDL_SCANCODE_T,
            u = SDL_SCANCODE_U,
            v = SDL_SCANCODE_V,
            w = SDL_SCANCODE_W,
            x = SDL_SCANCODE_X,
            y = SDL_SCANCODE_Y,
            z = SDL_SCANCODE_Z,
            alpha1 = SDL_SCANCODE_1,
            alpha2 = SDL_SCANCODE_2,
            alpha3 = SDL_SCANCODE_3,
            alpha4 = SDL_SCANCODE_4,
            alpha5 = SDL_SCANCODE_5,
            alpha6 = SDL_SCANCODE_6,
            alpha7 = SDL_SCANCODE_7,
            alpha8 = SDL_SCANCODE_8,
            alpha9 = SDL_SCANCODE_9,
            alpha0 = SDL_SCANCODE_0,
            enter = SDL_SCANCODE_RETURN,
            escape = SDL_SCANCODE_ESCAPE,
            backspace = SDL_SCANCODE_BACKSPACE,
            tab = SDL_SCANCODE_TAB,
            space = SDL_SCANCODE_SPACE,
            minus = SDL_SCANCODE_MINUS,
            equals = SDL_SCANCODE_EQUALS,
            leftBracket = SDL_SCANCODE_LEFTBRACKET,
            rightBracket = SDL_SCANCODE_RIGHTBRACKET,
            backslash = SDL_SCANCODE_BACKSLASH,
            nonushash = SDL_SCANCODE_NONUSHASH,
            semicolon = SDL_SCANCODE_SEMICOLON,
            apostrophe = SDL_SCANCODE_APOSTROPHE,
            grave = SDL_SCANCODE_GRAVE,
            comma = SDL_SCANCODE_COMMA,
            period = SDL_SCANCODE_PERIOD,
            slash = SDL_SCANCODE_SLASH,
            capslock = SDL_SCANCODE_CAPSLOCK,
            f1 = SDL_SCANCODE_F1,
            f2 = SDL_SCANCODE_F2,
            f3 = SDL_SCANCODE_F3,
            f4 = SDL_SCANCODE_F4,
            f5 = SDL_SCANCODE_F5,
            f6 = SDL_SCANCODE_F6,
            f7 = SDL_SCANCODE_F7,
            f8 = SDL_SCANCODE_F8,
            f9 = SDL_SCANCODE_F9,
            f10 = SDL_SCANCODE_F10,
            f11 = SDL_SCANCODE_F11,
            f12 = SDL_SCANCODE_F12,
            printScreen = SDL_SCANCODE_PRINTSCREEN,
            scrollLock = SDL_SCANCODE_SCROLLLOCK,
            pause = SDL_SCANCODE_PAUSE,
            insert = SDL_SCANCODE_INSERT,
            home = SDL_SCANCODE_HOME,
            pageup = SDL_SCANCODE_PAGEUP,
            remove = SDL_SCANCODE_DELETE,
            end = SDL_SCANCODE_END,
            pagedown = SDL_SCANCODE_PAGEDOWN,
            right = SDL_SCANCODE_RIGHT,
            left = SDL_SCANCODE_LEFT,
            down = SDL_SCANCODE_DOWN,
            up = SDL_SCANCODE_UP,
            numLockclear = SDL_SCANCODE_NUMLOCKCLEAR,
            numDivide = SDL_SCANCODE_KP_DIVIDE,
            numMultiply = SDL_SCANCODE_KP_MULTIPLY,
            numMinus = SDL_SCANCODE_KP_MINUS,
            numPlus = SDL_SCANCODE_KP_PLUS,
            numEnter = SDL_SCANCODE_KP_ENTER,
            num1 = SDL_SCANCODE_KP_1,
            num2 = SDL_SCANCODE_KP_2,
            num3 = SDL_SCANCODE_KP_3,
            num4 = SDL_SCANCODE_KP_4,
            num5 = SDL_SCANCODE_KP_5,
            num6 = SDL_SCANCODE_KP_6,
            num7 = SDL_SCANCODE_KP_7,
            num8 = SDL_SCANCODE_KP_8,
            num9 = SDL_SCANCODE_KP_9,
            num0 = SDL_SCANCODE_KP_0,
            numPeriod = SDL_SCANCODE_KP_PERIOD,
            nonusBackslash = SDL_SCANCODE_NONUSBACKSLASH,
            application = SDL_SCANCODE_APPLICATION,
            power = SDL_SCANCODE_POWER,
            numEquals = SDL_SCANCODE_KP_EQUALS,
            f13 = SDL_SCANCODE_F13,
            f14 = SDL_SCANCODE_F14,
            f15 = SDL_SCANCODE_F15,
            f16 = SDL_SCANCODE_F16,
            f17 = SDL_SCANCODE_F17,
            f18 = SDL_SCANCODE_F18,
            f19 = SDL_SCANCODE_F19,
            f20 = SDL_SCANCODE_F20,
            f21 = SDL_SCANCODE_F21,
            f22 = SDL_SCANCODE_F22,
            f23 = SDL_SCANCODE_F23,
            f24 = SDL_SCANCODE_F24,
            execute = SDL_SCANCODE_EXECUTE,
            help = SDL_SCANCODE_HELP,
            menu = SDL_SCANCODE_MENU,
            select = SDL_SCANCODE_SELECT,
            stop = SDL_SCANCODE_STOP,
            again = SDL_SCANCODE_AGAIN,
            undo = SDL_SCANCODE_UNDO,
            cut = SDL_SCANCODE_CUT,
            copy = SDL_SCANCODE_COPY,
            paste = SDL_SCANCODE_PASTE,
            find = SDL_SCANCODE_FIND,
            mute = SDL_SCANCODE_MUTE,
            volumeUp = SDL_SCANCODE_VOLUMEUP,
            volumeDown = SDL_SCANCODE_VOLUMEDOWN,
            numComma = SDL_SCANCODE_KP_COMMA,
            numEqualsAs400 = SDL_SCANCODE_KP_EQUALSAS400,
            international1 = SDL_SCANCODE_INTERNATIONAL1,
            international2 = SDL_SCANCODE_INTERNATIONAL2,
            international3 = SDL_SCANCODE_INTERNATIONAL3,
            international4 = SDL_SCANCODE_INTERNATIONAL4,
            international5 = SDL_SCANCODE_INTERNATIONAL5,
            international6 = SDL_SCANCODE_INTERNATIONAL6,
            international7 = SDL_SCANCODE_INTERNATIONAL7,
            international8 = SDL_SCANCODE_INTERNATIONAL8,
            international9 = SDL_SCANCODE_INTERNATIONAL9,
            lang1 = SDL_SCANCODE_LANG1,
            lang2 = SDL_SCANCODE_LANG2,
            lang3 = SDL_SCANCODE_LANG3,
            lang4 = SDL_SCANCODE_LANG4,
            lang5 = SDL_SCANCODE_LANG5,
            lang6 = SDL_SCANCODE_LANG6,
            lang7 = SDL_SCANCODE_LANG7,
            lang8 = SDL_SCANCODE_LANG8,
            lang9 = SDL_SCANCODE_LANG9,
            alterase = SDL_SCANCODE_ALTERASE,
            sysreq = SDL_SCANCODE_SYSREQ,
            cancel = SDL_SCANCODE_CANCEL,
            clear = SDL_SCANCODE_CLEAR,
            prior = SDL_SCANCODE_PRIOR,
            enter2 = SDL_SCANCODE_RETURN2,
            separator = SDL_SCANCODE_SEPARATOR,
            out_ = SDL_SCANCODE_OUT,
            oper = SDL_SCANCODE_OPER,
            clearAgain = SDL_SCANCODE_CLEARAGAIN,
            crsel = SDL_SCANCODE_CRSEL,
            exsel = SDL_SCANCODE_EXSEL,
            num00 = SDL_SCANCODE_KP_00,
            num000 = SDL_SCANCODE_KP_000,
            thousandSeparator = SDL_SCANCODE_THOUSANDSSEPARATOR,
            decimalSeparator = SDL_SCANCODE_DECIMALSEPARATOR,
            currencyUnit = SDL_SCANCODE_CURRENCYUNIT,
            currencySubunit = SDL_SCANCODE_CURRENCYSUBUNIT,
            numLeftParenthesis = SDL_SCANCODE_KP_LEFTPAREN,
            numRightParenthesis = SDL_SCANCODE_KP_RIGHTPAREN,
            numLeftBrace = SDL_SCANCODE_KP_LEFTBRACE,
            numRightBrace = SDL_SCANCODE_KP_RIGHTBRACE,
            numTab = SDL_SCANCODE_KP_TAB,
            numBackspace = SDL_SCANCODE_KP_BACKSPACE,
            numA = SDL_SCANCODE_KP_A,
            numB = SDL_SCANCODE_KP_B,
            numC = SDL_SCANCODE_KP_C,
            numD = SDL_SCANCODE_KP_D,
            numE = SDL_SCANCODE_KP_E,
            numF = SDL_SCANCODE_KP_F,
            numXor = SDL_SCANCODE_KP_XOR,
            numPower = SDL_SCANCODE_KP_POWER,
            numPercent = SDL_SCANCODE_KP_PERCENT,
            numLess = SDL_SCANCODE_KP_LESS,
            numGreater = SDL_SCANCODE_KP_GREATER,
            numAmpersand = SDL_SCANCODE_KP_AMPERSAND,
            numDblAmpersand = SDL_SCANCODE_KP_DBLAMPERSAND,
            numVerticalBar = SDL_SCANCODE_KP_VERTICALBAR,
            numDblVerticalBar = SDL_SCANCODE_KP_DBLVERTICALBAR,
            numColon = SDL_SCANCODE_KP_COLON,
            numHash = SDL_SCANCODE_KP_HASH,
            numSpace = SDL_SCANCODE_KP_SPACE,
            numAt = SDL_SCANCODE_KP_AT,
            numExclam = SDL_SCANCODE_KP_EXCLAM,
            numMemStore = SDL_SCANCODE_KP_MEMSTORE,
            numMemRecall = SDL_SCANCODE_KP_MEMRECALL,
            numMemClear = SDL_SCANCODE_KP_MEMCLEAR,
            numMemAdd = SDL_SCANCODE_KP_MEMADD,
            numMemSubtract = SDL_SCANCODE_KP_MEMSUBTRACT,
            numMemMultiply = SDL_SCANCODE_KP_MEMMULTIPLY,
            numMemDivide = SDL_SCANCODE_KP_MEMDIVIDE,
            numPlusMinus = SDL_SCANCODE_KP_PLUSMINUS,
            numClear = SDL_SCANCODE_KP_CLEAR,
            numClearEntry = SDL_SCANCODE_KP_CLEARENTRY,
            numBinary = SDL_SCANCODE_KP_BINARY,
            numOctal = SDL_SCANCODE_KP_OCTAL,
            numDecimal = SDL_SCANCODE_KP_DECIMAL,
            numHexadecimal = SDL_SCANCODE_KP_HEXADECIMAL,
            leftControl = SDL_SCANCODE_LCTRL,
            leftShift = SDL_SCANCODE_LSHIFT,
            leftAlt = SDL_SCANCODE_LALT,
            leftGUI = SDL_SCANCODE_LGUI,
            rightControl = SDL_SCANCODE_RCTRL,
            rightShift = SDL_SCANCODE_RSHIFT,
            rightAlt = SDL_SCANCODE_RALT,
            rightGUI = SDL_SCANCODE_RGUI,
            mode = SDL_SCANCODE_MODE,
            audioNext = SDL_SCANCODE_AUDIONEXT,
            audioPrev = SDL_SCANCODE_AUDIOPREV,
            audioStop = SDL_SCANCODE_AUDIOSTOP,
            audioPlay = SDL_SCANCODE_AUDIOPLAY,
            audioMute = SDL_SCANCODE_AUDIOMUTE,
            mediaSelect = SDL_SCANCODE_MEDIASELECT,
            www = SDL_SCANCODE_WWW,
            mail = SDL_SCANCODE_MAIL,
            calculator = SDL_SCANCODE_CALCULATOR,
            computer = SDL_SCANCODE_COMPUTER,
            acSearch = SDL_SCANCODE_AC_SEARCH,
            acHome = SDL_SCANCODE_AC_HOME,
            acBack = SDL_SCANCODE_AC_BACK,
            acForward = SDL_SCANCODE_AC_FORWARD,
            acStop = SDL_SCANCODE_AC_STOP,
            acRefresh = SDL_SCANCODE_AC_REFRESH,
            acBookmarks = SDL_SCANCODE_AC_BOOKMARKS,
            brightnessDown = SDL_SCANCODE_BRIGHTNESSDOWN,
            brightnessUp = SDL_SCANCODE_BRIGHTNESSUP,
            displaysWitch = SDL_SCANCODE_DISPLAYSWITCH,
            kbdIllumToggle = SDL_SCANCODE_KBDILLUMTOGGLE,
            kbdIllumDown = SDL_SCANCODE_KBDILLUMDOWN,
            kbdIllumUp = SDL_SCANCODE_KBDILLUMUP,
            eject = SDL_SCANCODE_EJECT,
            sleep = SDL_SCANCODE_SLEEP,
            app1 = SDL_SCANCODE_APP1,
            app2 = SDL_SCANCODE_APP2
        }

        /// Touche du clavier
        Button button;

        /// Est-ce que la touche est pressée ?
        bool pressed;

        /// Est-ce une répétition de touche automatique ?
        bool isEcho;

        /// Init
        this(Button button_, bool pressed_, bool isEcho_) {
            button = button_;
            pressed = pressed_;
            isEcho = isEcho_;
        }

        /// Copie
        this(const KeyButton event) {
            button = event.button;
            pressed = event.pressed;
            isEcho = event.isEcho;
        }
    }

    /// Touche de la souris
    final class MouseButton {
        /// Touches de la souris
        enum Button {
            left = SDL_BUTTON_LEFT,
            middle = SDL_BUTTON_MIDDLE,
            right = SDL_BUTTON_RIGHT,
            x1 = SDL_BUTTON_X1,
            x2 = SDL_BUTTON_X2,
        }

        /// Touche de la souris
        Button button;

        /// Est-ce que la touche est pressée ?
        bool pressed;

        /// Combien de fois cette touche a été appuyé ?
        uint clicks;

        /// Position relative à la racine
        vec2i globalPosition;

        /// Position relative au nœud actuel
        vec2i position;

        /// Init
        this(Button button_, bool pressed_, uint clicks_, vec2i globalPosition_, vec2i position_) {
            button = button_;
            pressed = pressed_;
            clicks = clicks_;
            globalPosition = globalPosition_;
            position = position_;
        }

        /// Copie
        this(const MouseButton event) {
            button = event.button;
            pressed = event.pressed;
            clicks = event.clicks;
            globalPosition = event.globalPosition;
            position = event.position;
        }
    }

    /// Déplacement de la souris
    final class MouseMotion {
        /// Position relative à la racine
        vec2i globalPosition;

        /// Position relative au nœud actuel
        vec2i position;

        /// Init
        this(vec2i globalPosition_, vec2i position_) {
            globalPosition = globalPosition_;
            position = position_;
        }

        /// Copie
        this(const MouseMotion event) {
            globalPosition = event.globalPosition;
            position = event.position;
        }
    }

    /// Molette de la souris
    final class MouseWheel {
        /// Molette
        vec2i wheel;

        /// Init
        this(vec2i wheel_) {
            wheel = wheel_;
        }

        /// Copie
        this(const MouseWheel event) {
            wheel = event.wheel;
        }
    }

    /// Texte entré par l’utilisateur
    final class TextInput {
        /// Texte
        string text;

        /// Init
        this(string text_) {
            text = text_;
        }

        /// Copie
        this(const TextInput event) {
            text = event.text;
        }
    }

    /// Fichier glissé/déposé dans la fenêtre de l’application
    final class DropFile {
        /// Chemin du fichier
        string path;

        /// Init
        this(string path_) {
            path = path_;
        }

        /// Copie
        this(const DropFile event) {
            path = event.path;
        }
    }

    private {
        Type _type;
        bool _isAccepted;

        union {
            KeyButton _keyButton;
            MouseButton _mouseButton;
            MouseMotion _mouseMotion;
            MouseWheel _mouseWheel;
            TextInput _textInput;
            DropFile _dropFile;
        }
    }

    @property {
        /// Type de l’événement
        Type type() const {
            return _type;
        }

        /// Si l’événement est de type KeyButton, le retourne, sinon retourne null
        KeyButton asKeyButton() {
            if (_type != Type.keyButton)
                return null;
            return _keyButton;
        }

        /// Si l’événement est de type MouseButton, le retourne, sinon retourne null
        MouseButton asMouseButton() {
            if (_type != Type.mouseButton)
                return null;
            return _mouseButton;
        }

        /// Si l’événement est de type MouseMotion, le retourne, sinon retourne null
        MouseMotion asMouseMotion() {
            if (_type != Type.mouseMotion)
                return null;
            return _mouseMotion;
        }

        /// Si l’événement est de type MouseWheel, le retourne, sinon retourne null
        MouseWheel asMouseWheel() {
            if (_type != Type.mouseWheel)
                return null;
            return _mouseWheel;
        }

        /// Si l’événement est de type TextInput, le retourne, sinon retourne null
        TextInput asTextInput() {
            if (_type != Type.textInput)
                return null;
            return _textInput;
        }

        /// Si l’événement est de type DropFile, le retourne, sinon retourne null
        DropFile asDropFile() {
            if (_type != Type.dropFile)
                return null;
            return _dropFile;
        }

        /// Cet événement peut-il servir d’action ?
        /// Voir InputMap
        bool isAction() const {
            switch (_type) with (Type) {
            case keyButton:
            case mouseButton:
                return true;
            default:
                return false;
            }
        }

        /// Dans le cas d’une touche ou d’un bouton, est-il appuyé ?
        bool isPressed() const {
            switch (_type) with (Type) {
            case keyButton:
                return _keyButton.pressed;
            case mouseButton:
                return _mouseButton.pressed;
            default:
                return false;
            }
        }

        /// Formate l’événement
        string prettify() const {
            string txt = __traits(identifier, typeof(this));
            string[] info;
            txt ~= "{ ";
            info ~= to!string(_type);

            final switch (_type) with (Type) {
            case none:
                break;
            case keyButton:
                info ~= "button: " ~ to!string(_keyButton.button);
                info ~= _keyButton.pressed ? "pressed" : "released";
                if (_keyButton.isEcho)
                    info ~= "echo";
                break;
            case mouseButton:
                info ~= "button: " ~ to!string(_mouseButton.button);
                info ~= _mouseButton.pressed ? "pressed" : "released";
                info ~= "clicks: " ~ to!string(_mouseButton.clicks);
                info ~= "globalPosition: " ~ to!string(_mouseButton.globalPosition);
                info ~= "position: " ~ to!string(_mouseButton.position);
                break;
            case mouseMotion:
                info ~= "globalPosition: " ~ to!string(_mouseMotion.globalPosition);
                info ~= "position: " ~ to!string(_mouseMotion.position);
                break;
            case mouseWheel:
                info ~= "wheel: " ~ to!string(_mouseWheel.wheel);
                break;
            case textInput:
                info ~= "text: " ~ to!string(_textInput.text);
                break;
            case dropFile:
                info ~= "path: " ~ to!string(_dropFile.path);
                break;
            }
            txt ~= info.join(", ");
            txt ~= " }";
            return txt;
        }

        /// L’événement a-t’il été consommé ?
        final isAccepted() const {
            return _isAccepted;
        }
    }

    private this() {
    }

    /// Copie
    this(const InputEvent event) {
        _type = event._type;
        _isAccepted = event._isAccepted;

        final switch (_type) with (Type) {
        case none:
            break;
        case keyButton:
            _keyButton = new KeyButton(event._keyButton);
            break;
        case mouseButton:
            _mouseButton = new MouseButton(event._mouseButton);
            break;
        case mouseMotion:
            _mouseMotion = new MouseMotion(event._mouseMotion);
            break;
        case mouseWheel:
            _mouseWheel = new MouseWheel(event._mouseWheel);
            break;
        case textInput:
            _textInput = new TextInput(event._textInput);
            break;
        case dropFile:
            _dropFile = new DropFile(event._dropFile);
            break;
        }
    }

    private {
        void _makeKeyButton(KeyButton.Button button, bool pressed, bool isEcho) {
            _keyButton = new KeyButton(button, pressed, isEcho);
        }

        void _makeMouseButton(MouseButton.Button button, bool pressed,
            uint clicks, vec2i globalPosition, vec2i position) {
            _mouseButton = new MouseButton(button, pressed, clicks, globalPosition, position);
        }

        void _makeMouseMotion(vec2i globalPosition, vec2i position) {
            _mouseMotion = new MouseMotion(globalPosition, position);
        }

        void _makeMouseWheel(vec2i wheel) {
            _mouseWheel = new MouseWheel(wheel);
        }

        void _makeTextInput(string text) {
            _textInput = new TextInput(text);
        }

        void _makeDropFile(string path) {
            _dropFile = new DropFile(path);
        }
    }

    /// Touche du clavier
    static {
        /// Retourne un événement correspondant à une touche du clavier
        InputEvent keyButton(KeyButton.Button button, bool pressed, bool isEcho) {
            InputEvent event = new InputEvent;
            event._type = Type.keyButton;
            event._isAccepted = false;
            event._makeKeyButton(button, pressed, isEcho);
            return event;
        }

        /// Retourne un événement correspondant à une touche de la souris
        InputEvent mouseButton(MouseButton.Button button, bool pressed,
            uint clicks, vec2i globalPosition, vec2i position) {
            InputEvent event = new InputEvent;
            event._type = Type.mouseButton;
            event._isAccepted = false;
            event._makeMouseButton(button, pressed, clicks, globalPosition, position);
            return event;
        }

        /// Retourne un événement correspondant à un déplacement de la souris
        InputEvent mouseMotion(vec2i globalPosition, vec2i position) {
            InputEvent event = new InputEvent;
            event._type = Type.mouseMotion;
            event._isAccepted = false;
            event._makeMouseMotion(globalPosition, position);
            return event;
        }

        /// Retourne un événement correspondant à un mouvement de la molette de la souris
        InputEvent mouseWheel(vec2i wheel) {
            InputEvent event = new InputEvent;
            event._type = Type.mouseWheel;
            event._isAccepted = false;
            event._makeMouseWheel(wheel);
            return event;
        }

        /// Retourne un événement correspondant à un mouvement de la molette de la souris
        InputEvent textInput(string text) {
            InputEvent event = new InputEvent;
            event._type = Type.textInput;
            event._isAccepted = false;
            event._makeTextInput(text);
            return event;
        }

        /// Retourne un événement correspondant à un mouvement de la molette de la souris
        InputEvent dropFile(string path) {
            InputEvent event = new InputEvent;
            event._type = Type.dropFile;
            event._isAccepted = false;
            event._makeDropFile(path);
            return event;
        }
    }

    /// L’événement correspond-t’il à l’autre ?
    bool match(const InputEvent event) const {
        switch (_type) with (Type) {
        case keyButton:
            return _keyButton.button == event._keyButton.button;
        case mouseButton:
            return _mouseButton.button == event._mouseButton.button;
        default:
            return false;
        }
    }

    /// Consomme l’événement et empêche sa propagation
    void accept() {
        _isAccepted = true;
    }
}
