module magia.core.cli;

import std.string;
import std.exception;

/// Outil de gestion de ligne de commande
final class Cli {
    /// Résultat de l’analyse des arguments
    final class Result {
        private class Option {
            private {
                string _shortName, _longName;
                string[] _requiredParams, _optionalParams;
            }

            @property {
                string shortName() const {
                    return _shortName;
                }

                string longName() const {
                    return _longName;
                }

                const(string[]) requiredParams() const {
                    return _requiredParams;
                }

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
    }

    private alias Callback = void function(Result);

    private final class Option {
        private {
            string _shortName, _longName, _info;
            uint _requiredParams, _optionalParams;
        }

        this(string shortName, string longName, uint requiredParams = 0, uint optionalParams = 0) {
            _shortName = shortName;
            _longName = longName;
            _requiredParams = requiredParams;
            _optionalParams = optionalParams;
        }

        Option info(string info_) {
            _info = info_;
            return this;
        }
    }

    private final class Command {
        private {
            string _name, _info;
            uint _requiredParams, _optionalParams;
            Option[] _options;
            Callback _callback;
        }

        this(Callback callback, string name, uint requiredParams = 0, uint optionalParams = 0) {
            _callback = callback;
            _name = name;
            _requiredParams = requiredParams;
            _optionalParams = optionalParams;
        }

        Command addOption(Option option) {
            _options ~= option;
            return this;
        }

        Command info(string info_) {
            _info = info_;
            return this;
        }
    }

    private {
        string _info;
        Command[] _commands;
        Option[] _options;
        Callback _defaultCallback;
    }

    /// Ctor
    this() {
    }

    /// Définit le comportement par défaut si aucune commande n’est appelé
    void setDefault(Callback callback) {
        _defaultCallback = callback;
    }

    /// Ajoute une option
    void addOption(string shortName, string longName, uint requiredParams = 0,
        uint optionalParams = 0) {
        _options ~= new Option(shortName, longName, requiredParams, optionalParams);
    }

    /// Ajoute une commande
    void addCommand(Callback callback, string name, uint requiredParams = 0, uint optionalParams = 0) {
        _commands ~= new Command(callback, name, requiredParams, optionalParams);
    }

    /// Ajoute une option à une commande
    void addCommandOption(string name, string shortName, string longName,
        uint requiredParams = 0, uint optionalParams = 0) {
        foreach (command; _commands) {
            if (command._name == name) {
                command._options ~= new Option(shortName, longName,
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

            enforce(false, "commande inconnue");
        }

        private void _parseCommand() {
            enforce(_args.length >= _command._requiredParams, "paramètres manquants");
            string[] requiredParams = _args[0 .. _command._requiredParams];
            _args = _args[_command._requiredParams .. $];
            foreach (param; requiredParams) {
                enforce(indexOf(param, "-") != 0, "paramètres manquants");
            }

            string[] optionalParams;
            while (_args.length && optionalParams.length < _command._optionalParams) {
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
                if (indexOf(cmd, "--") == 0) {
                    cmd = cmd[2 .. $];
                    foreach (Option option; _command ? _command._options : _cli._options) {
                        if (cmd == option._longName) {
                            _args = _args[1 .. $];
                            _parseOption(option);
                            break;
                        }
                    }
                } else {
                    cmd = cmd[1 .. $];
                    foreach (Option option; _command ? _command._options : _cli._options) {
                        if (cmd == option._shortName) {
                            _args = _args[1 .. $];
                            _parseOption(option);
                            break;
                        }
                    }
                }

                if (!_args.length)
                    break;

                cmd = _args[0];
            }

            return hasOptions;
        }

        private void _parseOption(Option option) {
            enforce(_args.length >= option._requiredParams, "paramètres manquants");
            string[] requiredParams = _args[0 .. option._requiredParams];
            _args = _args[option._requiredParams .. $];
            foreach (param; requiredParams) {
                enforce(indexOf(param, "-") != 0, "paramètres manquants");
            }

            string[] optionalParams;
            while (_args.length && optionalParams.length < option._optionalParams) {
                if (indexOf(_args[0], "-") == 0)
                    break;
                optionalParams ~= _args[0];
                _args = _args[1 .. $];
            }

            _result.addOption(option._shortName, option._longName, requiredParams, optionalParams);
        }
    }

    /// Analyse une liste d’arguments en ligne de commande
    void parse(string[] args) {
        State state = new State(this, args);
        state.run();
    }
}
