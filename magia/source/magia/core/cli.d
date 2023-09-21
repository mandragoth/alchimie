module magia.core.cli;

import std.stdio;
import std.string;
import std.exception;

/// Outil de gestion de ligne de commande
final class Cli {
    /// Résultat de l’analyse des arguments
    final class Result {
        /// Modifieur de commande
        final class Option {
            private {
                string _shortName, _longName;
                string[] _requiredParams, _optionalParams;
            }

            @property {
                /// Nom sous format `-x` sans le `-`
                string shortName() const {
                    return _shortName;
                }

                /// Nom sous format `--xxxx` sans le `--`
                string longName() const {
                    return _longName;
                }

                /// Liste des paramètres obligatoires
                const(string[]) requiredParams() const {
                    return _requiredParams;
                }

                /// Liste des paramètres optionnels
                const(string[]) optionalParams() const {
                    return _optionalParams;
                }
            }

            private this(string shortName_, string longName_,
                string[] requiredParams_, string[] optionalParams_) {
                _shortName = shortName_;
                _longName = longName_;
                _requiredParams = requiredParams_;
                _optionalParams = optionalParams_;
            }
        }

        private {
            Cli _cli;
            string _name;
            string[] _requiredParams, _optionalParams;
            Option[] _options;
        }

        @property {
            /// Nom de la commande (si présent)
            string name() const {
                return _name;
            }

            /// Paramètres obligatoires
            const(string[]) requiredParams() const {
                return _requiredParams;
            }

            /// Paramètres optionnels
            const(string[]) optionalParams() const {
                return _optionalParams;
            }
        }

        private this(Cli cli) {
            _cli = cli;
        }

        private void setName(string name_) {
            _name = name_;
        }

        private void setParams(string[] requiredParams_, string[] optionalParams_) {
            _requiredParams = requiredParams_;
            _optionalParams = optionalParams_;
        }

        private void addOption(string shortName, string longName,
            string[] requiredParams_, string[] optionalParams_) {
            enforce(!hasOption(shortName), "une option est déjà définie pour `" ~ shortName ~ "`");
            enforce(!hasOption(longName), "une option est déjà définie pour `" ~ longName ~ "`");

            _options ~= new Option(shortName, longName, requiredParams_, optionalParams_);
        }

        /// Vérifie la présence d’une option
        bool hasOption(string name) {
            if (!name.length)
                return false;

            foreach (Option option; _options) {
                if (option.shortName == name || option.longName == name)
                    return true;
            }
            return false;
        }

        /// Récupère une option
        Option getOption(string name) {
            foreach (Option option; _options) {
                if (option.shortName == name || option.longName == name)
                    return option;
            }
            return null;
        }

        string getHelp() {
            return _cli.getHelp();
        }

        string getHelp(string name_) {
            return _cli.getHelp(name_);
        }
    }

    private alias Callback = void function(Result);

    private final class Option {
        private {
            string _shortName, _longName, _info;
            string[] _requiredParams, _optionalParams;
        }

        this(string shortName, string longName, string info,
            string[] requiredParams = [], string[] optionalParams = []) {
            _shortName = shortName;
            _longName = longName;
            _info = info;
            _requiredParams = requiredParams;
            _optionalParams = optionalParams;
        }
    }

    private final class Command {
        private {
            string _name, _info;
            string[] _requiredParams, _optionalParams;
            Option[] _options;
            Callback _callback;
        }

        this(Callback callback, string name, string info,
            string[] requiredParams = [], string[] optionalParams = []) {
            _callback = callback;
            _name = name;
            _info = info;
            _requiredParams = requiredParams;
            _optionalParams = optionalParams;
        }

        /// Vérifie la présence d’une option
        private bool hasOption(string name) {
            if (!name.length)
                return false;

            foreach (Option option; _options) {
                if (option._shortName == name || option._longName == name)
                    return true;
            }
            return false;
        }

        Command addOption(Option option) {
            enforce(!hasOption(option._shortName),
                "une option est déjà définie pour `" ~ option._shortName ~
                "` pour la commande `" ~ _name ~ "`");
            enforce(!hasOption(option._longName),
                "une option est déjà définie pour `" ~ option._longName ~
                "` pour la commande `" ~ _name ~ "`");
            _options ~= option;
            return this;
        }
    }

    private {
        string _name;
        Command[] _commands;
        Option[] _options;
        Callback _defaultCallback;
    }

    /// Ctor
    this(string name) {
        _name = name;
    }

    /// Vérifie la présence d’une commande
    private bool hasCommand(string name) {
        foreach (Command command; _commands) {
            if (command._name == name)
                return true;
        }
        return false;
    }

    /// Vérifie la présence d’une option
    private bool hasOption(string name) {
        if (!name.length)
            return false;

        foreach (Option option; _options) {
            if (option._shortName == name || option._longName == name)
                return true;
        }
        return false;
    }

    /// Définit le comportement par défaut si aucune commande n’est appelé
    void setDefault(Callback callback) {
        _defaultCallback = callback;
    }

    /// Ajoute une option
    void addOption(string shortName, string longName, string info,
        string[] requiredParams = [], string[] optionalParams = []) {
        enforce(shortName.length || longName.length, "l’option doit avoir au moins un nom");
        enforce(!hasOption(shortName), "une option est déjà définie pour `" ~ shortName ~ "`");
        enforce(!hasOption(longName), "une option est déjà définie pour `" ~ longName ~ "`");

        _options ~= new Option(shortName, longName, info, requiredParams, optionalParams);
    }

    /// Ajoute une commande
    void addCommand(Callback callback, string name, string info,
        string[] requiredParams = [], string[] optionalParams = []) {
        enforce(!hasCommand(name), "une commande est déjà définie pour `" ~ name ~ "`");

        _commands ~= new Command(callback, name, info, requiredParams, optionalParams);
    }

    /// Ajoute une option à une commande
    void addCommandOption(string name, string shortName, string longName,
        string info, string[] requiredParams = [], string[] optionalParams = []) {
        enforce(shortName.length || longName.length, "l’option doit avoir au moins un nom");

        foreach (command; _commands) {
            if (command._name == name) {
                command._options ~= new Option(shortName, longName, info,
                    requiredParams, optionalParams);
                return;
            }
        }
        enforce(false, "aucune commande `" ~ name ~ "` trouvé");
    }

    private final class State {
        private {
            string[] _args;
            Cli _cli;
            Command _command;
            Result _result;
            string _exeName;
        }

        this(Cli cli, string[] args) {
            _cli = cli;

            enforce(args.length >= 1, "arguments manquant");
            _exeName = args[0];
            _args = args[1 .. $];
        }

        void run() {
            _result = new Result(_cli);
            if (!_args.length || _parseOptions()) {
                if (_cli._defaultCallback)
                    _cli._defaultCallback(_result);
                return;
            }

            string cmd = _args[0];
            foreach (Command command; _cli._commands) {
                if (cmd == command._name) {
                    _command = command;
                    _result.setName(_command._name);
                    _args = _args[1 .. $];
                    _parseCommand();
                    _command._callback(_result);
                    return;
                }
            }

            enforce(false, "commande inconnue `" ~ cmd ~ "`");
        }

        private void _parseCommand() {
            enforce(_args.length >= _command._requiredParams.length, "paramètres manquants");
            string[] requiredParams = _args[0 .. _command._requiredParams.length];
            _args = _args[_command._requiredParams.length .. $];
            foreach (param; requiredParams) {
                enforce(indexOf(param, "-") != 0, "paramètres manquants");
            }

            string[] optionalParams;
            while (_args.length && optionalParams.length < _command._optionalParams.length) {
                if (indexOf(_args[0], "-") == 0)
                    break;
                optionalParams ~= _args[0];
                _args = _args[1 .. $];
            }

            _result.setParams(requiredParams, optionalParams);

            _parseOptions();
        }

        private bool _parseOptions() {
            if (!_args.length)
                return false;

            bool hasOptions;
            string cmd = _args[0];

            while (indexOf(cmd, "-") == 0) {
                hasOptions = true;
                Option currentOption = null;
                if (indexOf(cmd, "--") == 0) {
                    cmd = cmd[2 .. $];
                    enforce(cmd.length, "une option est vide");

                    foreach (Option option; _command ? _command._options : _cli._options) {
                        if (cmd == option._longName && option._longName.length) {
                            _args = _args[1 .. $];
                            currentOption = option;
                            _parseOption(option);
                            break;
                        }
                    }
                } else {
                    cmd = cmd[1 .. $];
                    enforce(cmd.length, "une option est vide");

                    foreach (Option option; _command ? _command._options : _cli._options) {
                        if (cmd == option._shortName && option._shortName.length) {
                            _args = _args[1 .. $];
                            currentOption = option;
                            _parseOption(option);
                            break;
                        }
                    }
                }

                if (_command)
                    enforce(currentOption,
                        "l’option `" ~ cmd ~ "` n’est pas reconnue par la commande `" ~
                        _command._name ~ "`");
                else
                    enforce(currentOption, "l’option `" ~ cmd ~ "` n’est pas reconnue");

                if (!_args.length)
                    break;

                cmd = _args[0];
            }

            return hasOptions;
        }

        private void _parseOption(Option option) {
            enforce(_args.length >= option._requiredParams.length, "paramètres manquants");
            string[] requiredParams = _args[0 .. option._requiredParams.length];
            _args = _args[option._requiredParams.length .. $];
            foreach (param; requiredParams) {
                enforce(indexOf(param, "-") != 0, "paramètres manquants");
            }

            string[] optionalParams;
            while (_args.length && optionalParams.length < option._optionalParams.length) {
                if (indexOf(_args[0], "-") == 0)
                    break;
                optionalParams ~= _args[0];
                _args = _args[1 .. $];
            }

            _result.addOption(option._shortName, option._longName, requiredParams, optionalParams);
        }
    }

    string getHelp() {
        string result = "Options:\n";
        foreach (option; _options) {
            string msg = "  ";
            if (option._shortName.length && option._longName.length)
                msg ~= "-" ~ option._shortName ~ "|--" ~ option._longName;
            else if (option._shortName.length)
                msg ~= "-" ~ option._shortName;
            else if (option._longName.length)
                msg ~= "--" ~ option._longName;
            else
                continue;

            foreach (param; option._requiredParams) {
                msg ~= " <" ~ param ~ ">";
            }
            foreach (param; option._optionalParams) {
                msg ~= " [" ~ param ~ "]";
            }
            msg = leftJustify(msg, 24);
            if (msg[$ - 1] != ' ')
                msg ~= "\n" ~ leftJustify("", 24);

            msg ~= option._info;
            result ~= msg ~ "\n";
        }
        result ~= "\nCommandes:\n";
        foreach (command; _commands) {
            string msg = "  " ~ command._name;
            foreach (param; command._requiredParams) {
                msg ~= " <" ~ param ~ ">";
            }
            foreach (param; command._optionalParams) {
                msg ~= " [" ~ param ~ "]";
            }
            msg = leftJustify(msg, 24);
            if (msg[$ - 1] != ' ')
                msg ~= "\n" ~ leftJustify("", 24);

            msg ~= command._info;
            result ~= msg ~ "\n";
        }
        return result;
    }

    string getHelp(string name) {
        Command command;
        foreach (command_; _commands) {
            if (command_._name == name) {
                command = command_;
            }
        }
        enforce(command, "aucune commande `" ~ name ~ "` trouvé");

        string result;
        {
            string msg = "Usage:\n  " ~ _name ~ " " ~ command._name;
            foreach (param; command._requiredParams) {
                msg ~= " <" ~ param ~ ">";
            }
            foreach (param; command._optionalParams) {
                msg ~= " [" ~ param ~ "]";
            }
            result ~= msg ~ "\n";
        }

        {
            result ~= "\nOptions:\n";
            foreach (option; command._options) {
                string msg = "  ";
                if (option._shortName.length && option._longName.length)
                    msg ~= "-" ~ option._shortName ~ "|--" ~ option._longName;
                else if (option._shortName.length)
                    msg ~= "-" ~ option._shortName;
                else if (option._longName.length)
                    msg ~= "--" ~ option._longName;
                else
                    continue;

                foreach (param; option._requiredParams) {
                    msg ~= " <" ~ param ~ ">";
                }
                foreach (param; option._optionalParams) {
                    msg ~= " [" ~ param ~ "]";
                }
                msg = leftJustify(msg, 24);
                if (msg[$ - 1] != ' ')
                    msg ~= "\n" ~ leftJustify("", 24);

                msg ~= option._info;
                result ~= msg ~ "\n";
            }
        }
        return result;
    }

    /// Analyse une liste d’arguments en ligne de commande
    void parse(string[] args) {
        State state = new State(this, args);
        try {
            state.run();
        } catch (Exception e) {
            writeln("\033[1;91mErreur:\033[0;0m " ~ e.msg);

            if (state._command) {
                writeln("\n", getHelp(state._command._name));
            } else {
                writeln("\n", getHelp());
            }
        }
    }
}
