/**
    Controller

    Copyright: (c) Enalye 2017
    License: Zlib
    Authors: Enalye
*/

module magia.common.controller;

import bindbc.sdl;
import magia.core;
import magia.common.resource;

import std.string;
import std.file: exists;
import std.stdio: writeln, printf;
import std.path;

private struct Controller {
    SDL_GameController* sdlController;
    SDL_Joystick* sdlJoystick;
    int index, joystickId;
}

private {
    Controller[] _controllers;

    Timer[6] _analogTimers, _analogTimeoutTimers;

    Vec2f _left = Vec2f.zero, _right = Vec2f.zero;

    bool _buttonA, _buttonB, _buttonX, _buttonY,
        _buttonSelect, _buttonMode, _buttonStart,
        _buttonL1, _buttonR1, _buttonL2, _buttonR2, _buttonL3, _buttonR3,
        _buttonLeft, _buttonRight, _buttonUp, _buttonDown;

    bool _singleButtonA, _singleButtonB, _singleButtonX, _singleButtonY,
        _singleButtonSelect, _singleButtonMode, _singleButtonStart,
        _singleButtonL1, _singleButtonR1, _singleButtonL2, _singleButtonR2, _singleButtonL3, _singleButtonR3,
        _singleButtonLeft, _singleButtonRight, _singleButtonUp, _singleButtonDown;
}

/// Open all the connected controllers
void initializeControllers() {
    foreach(index; 0.. SDL_NumJoysticks())
        addController(index);
    SDL_GameControllerEventState(SDL_ENABLE);
}

/// Close all the connected controllers
void destroyControllers() {
    foreach(ref controller; _controllers)
        SDL_GameControllerClose(controller.sdlController);
}

/// Register all controller definitions in a file, must be a valid format.
void addControllerMappingsFromFile(string filePath) {
    if(!exists(filePath))
        throw new Exception("Could not find \'" ~ filePath ~ "\'.");
    //if(-1 == SDL_GameControllerAddMappingsFromFile(toStringz(filePath)))
    //    throw new Exception("Invalid mapping file \'" ~ filePath ~ "\'.");
}

/// Register a controller definition, must be a valid format.
void addControllerMapping(string mapping) {
    if(-1 == SDL_GameControllerAddMapping(toStringz(mapping)))
        throw new Exception("Invalid mapping.");
}

/// Update the state of the controllers
void updateControllers(float deltaTime) {
    foreach(axisIndex; 0.. 4) {
        _analogTimers[axisIndex].update(deltaTime);
        _analogTimeoutTimers[axisIndex].update(deltaTime);
    }
}

/// Attempt to connect a new controller
void addController(int index) {
    writeln("Detected device at index ", index, ".");

    auto c = SDL_JoystickNameForIndex(index);
    auto d = fromStringz(c);
    writeln("Device name: ", d);
    
    if(!SDL_IsGameController(index)) {
        writeln("The device is not recognised as a game controller.");
        auto stick = SDL_JoystickOpen(index);
        auto guid = SDL_JoystickGetGUID(stick);
        writeln("The device guid is: ");
        foreach(i; 0.. 16)
            printf("%02x", guid.data[i]);
        writeln("");
        return;
    }
    writeln("The device has been detected as a game controller.");
    foreach(ref controller; _controllers) {
        if(controller.index == index) {
            writeln("The controller is already open, aborted.");
            return;
        }
    }

    auto sdlController = SDL_GameControllerOpen(index);
    if(!sdlController) {
        writeln("Could not connect the game controller.");
        return;
    }

    Controller controller;
    controller.sdlController = sdlController;
    controller.index = index;
    controller.sdlJoystick = SDL_GameControllerGetJoystick(controller.sdlController);
    controller.joystickId = SDL_JoystickInstanceID(controller.sdlJoystick);
    _controllers ~= controller;

    writeln("The game controller is now connected.");      
}

/// Remove a connected controller
void removeController(int joystickId) {
    writeln("Controller disconnected: ", joystickId);
    
    int index;
    bool isControllerPresent;
    foreach(ref controller; _controllers) {
        if(controller.joystickId == joystickId) {
            isControllerPresent = true;
            break;
        }
        index ++;
    }

    if(!isControllerPresent)
        return;

    SDL_GameControllerClose(_controllers[index].sdlController);

    //Remove from list
    if(index + 1 == _controllers.length)
        _controllers.length --;
    else if(index == 0)
        _controllers = _controllers[1.. $];
    else
        _controllers = _controllers[0.. index] ~ _controllers[(index + 1) .. $];
}

/// Called upon remapping
void remapController(int joystickId) {
    writeln("Controller remapped: ", joystickId);
}

/// Change the value of a controller axis.
void setControllerAxis(SDL_GameControllerAxis axis, short value) {
    auto v = rlerp(-32_768, 32_767, cast(float)value) * 2f - 1f;  
    switch(axis) {
    case SDL_CONTROLLER_AXIS_LEFTX:
        _left.x = v;
        break;
    case SDL_CONTROLLER_AXIS_LEFTY:
        _left.y = v;
        break;
    case SDL_CONTROLLER_AXIS_RIGHTX:
        _right.x = v;
        break;
    case SDL_CONTROLLER_AXIS_RIGHTY:
        _right.y = v;
        break;
    case SDL_CONTROLLER_AXIS_TRIGGERLEFT:
        _buttonL2 = v > .1f;
        break;
    case SDL_CONTROLLER_AXIS_TRIGGERRIGHT:
        _buttonR2 = v > .1f;
        break;
    default:
        break;
    }
}

/// Handle the timing of the axis
private bool updateAnalogTimer(int axisIndex, float x, float y) {
    if(axisIndex == -1)
        return false;

    enum deadzone = .5f;
    if((x < deadzone && x > -deadzone) && (y < deadzone && y > -deadzone))  {
        _analogTimeoutTimers[axisIndex].stop();
        return false;
    }
    else {
        if(_analogTimers[axisIndex].isRunning)
            return false;
        _analogTimers[axisIndex].start(_analogTimeoutTimers[axisIndex].isRunning ? .15f : .35f);
        _analogTimeoutTimers[axisIndex].start(5f);
    }
    return true;
}

/// Change the value of a controller button.
void setControllerButton(SDL_GameControllerButton button, bool state) {
    switch(button) {
    case SDL_CONTROLLER_BUTTON_A:
        _buttonA = state;
        _singleButtonA = state;
        break;
    case SDL_CONTROLLER_BUTTON_B:
        _buttonB = state;
        _singleButtonB = state;
        break;
    case SDL_CONTROLLER_BUTTON_X:
        _buttonX = state;
        _singleButtonX = state;
        break;
    case SDL_CONTROLLER_BUTTON_Y:
        _buttonY = state;
        _singleButtonY = state;
        break;
    case SDL_CONTROLLER_BUTTON_BACK:
        _buttonSelect = state;
        _singleButtonSelect = state;
        break;
    case SDL_CONTROLLER_BUTTON_GUIDE:
        _buttonMode = state;
        _singleButtonMode = state;
        break;
    case SDL_CONTROLLER_BUTTON_START:
        _buttonStart = state;
        _singleButtonStart = state;
        break;
    case SDL_CONTROLLER_BUTTON_LEFTSTICK:
        _buttonL3 = state;
        _singleButtonL3 = state;
        break;
    case SDL_CONTROLLER_BUTTON_RIGHTSTICK:
        _buttonR3 = state;
        _singleButtonR3 = state;
        break;
    case SDL_CONTROLLER_BUTTON_LEFTSHOULDER:
        _buttonL1 = state;
        _singleButtonL1 = state;
        break;
    case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER:
        _buttonR1 = state;
        _singleButtonR1 = state;
        break;
    case SDL_CONTROLLER_BUTTON_DPAD_UP:
        _buttonUp = state;
        _singleButtonUp = state;
        break;
    case SDL_CONTROLLER_BUTTON_DPAD_DOWN:
        _buttonDown = state;
        _singleButtonDown = state;
        break;
    case SDL_CONTROLLER_BUTTON_DPAD_LEFT:
        _buttonLeft = state;
        _singleButtonLeft = state;
        break;
    case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:
        _buttonRight = state;
        _singleButtonRight = state;
        break;
    default:
        break;
    }
}

@property {
    /// Left analog stick
    Vec2f getControllerInputLAnalog() {
        return _left;
    }

    /// Right analog stick
    Vec2f getControllerInputRAnalog() {
        return _right;
    }

    //Continuous buttons

    /// Is the A button pressed.
    bool getControllerInputA() {
        _singleButtonA = false;
        return _buttonA;
    }

    /// Is the B button pressed.
    bool getControllerInputB() {
        _singleButtonB = false;
        return _buttonB;
    }

    /// Is the X button pressed.
    bool getControllerInputX() {
        _singleButtonX = false;
        return _buttonX;
    }

    /// Is the Y button pressed.
    bool getControllerInputY() {
        _singleButtonY = false;
        return _buttonY;
    }

    /// Is the Select button pressed.
    bool getControllerInputSelect() {
        _singleButtonSelect = false;
        return _buttonSelect;
    }

    /// Is the Mode button pressed.
    bool getControllerInputMode() {
        _singleButtonMode = false;
        return _buttonMode;
    }

    /// Is the Start button pressed.
    bool getControllerInputStart() {
        _singleButtonStart = false;
        return _buttonStart;
    }

    /// Is the L1 button pressed.
    bool getControllerInputL1() {
        _singleButtonL1 = false;
        return _buttonL1;
    }

    /// Is the R1 button pressed.
    bool getControllerInputR1() {
        _singleButtonR1 = false;
        return _buttonR1;
    }

    /// Is the L2 button pressed.
    bool getControllerInputL2() {
        _singleButtonL2 = false;
        return _buttonL2;
    }

    /// Is the R2 button pressed.
    bool getControllerInputR2() {
        _singleButtonR2 = false;
        return _buttonR2;
    }

    /// Is the L3 button pressed.
    bool getControllerInputL3() {
        _singleButtonL3 = false;
        return _buttonL3;
    }

    /// Is the R3 button pressed.
    bool getControllerInputR3() {
        _singleButtonR3 = false;
        return _buttonR3;
    }

    /// Is the Left button pressed.
    bool getControllerInputLeft() {
        _singleButtonLeft = false;
        return _buttonLeft;
    }

    /// Is the Right button pressed.
    bool getControllerInputRight() {
        _singleButtonRight = false;
        return _buttonRight;
    }

    /// Is the Up button pressed.
    bool getControllerInputUp() {
        _singleButtonUp = false;
        return _buttonUp;
    }

    /// Is the Down button pressed.
    bool getControllerInputDown() {
        _singleButtonDown = false;
        return _buttonDown;
    }

    //Single action buttons

    /// Is the A button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleA() {
        auto state = _singleButtonA;
        _singleButtonA = false;
        return state;
    }

    /// Is the B button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleB() {
        auto state = _singleButtonB;
        _singleButtonB = false;
        return state;
    }

    /// Is the X button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleX() {
        auto state = _singleButtonX;
        _singleButtonX = false;
        return state;
    }

    /// Is the Y button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleY() {
        auto state = _singleButtonY;
        _singleButtonY = false;
        return state;
    }

    /// Is the Select button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleSelect() {
        auto state = _singleButtonSelect;
        _singleButtonSelect = false;
        return state;
    }

    /// Is the Mode button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleMode() {
        auto state = _singleButtonMode;
        _singleButtonMode = false;
        return state;
    }

    /// Is the Start button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleStart() {
        auto state = _singleButtonStart;
        _singleButtonStart = false;
        return state;
    }

    /// Is the L1 button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleL1() {
        auto state = _singleButtonL1;
        _singleButtonL1 = false;
        return state;
    }

    /// Is the R1 button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleR1() {
        auto state = _singleButtonR1;
        _singleButtonR1 = false;
        return state;
    }

    /// Is the L2 button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleL2() {
        auto state = _singleButtonL2;
        _singleButtonL2 = false;
        return state;
    }

    /// Is the R2 button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleR2() {
        auto state = _singleButtonR2;
        _singleButtonR2 = false;
        return state;
    }

    /// Is the L3 button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleL3() {
        auto state = _singleButtonL3;
        _singleButtonL3 = false;
        return state;
    }

    /// Is the R3 button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleR3() {
        auto state = _singleButtonR3;
        _singleButtonR3 = false;
        return state;
    }

    /// Is the Left button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleLeft() {
        auto state = _singleButtonLeft;
        _singleButtonLeft = false;
        return state;
    }

    /// Is the Right button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleRight() {
        auto state = _singleButtonRight;
        _singleButtonRight = false;
        return state;
    }

    /// Is the Up button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleUp() {
        auto state = _singleButtonUp;
        _singleButtonUp = false;
        return state;
    }

    /// Is the Down button pressed.
    /// Returns true only if the button was not already tested.
    bool getControllerInputSingleDown() {
        auto state = _singleButtonDown;
        _singleButtonDown = false;
        return state;
    }

    /// Returns the left stick x-axis as a button.
    bool getControllerInputSingleLeftX() {
        return updateAnalogTimer(0, _left.x, 0f);
    }

    /// Returns the left stick y-axis as a button.
    bool getControllerInputSingleLeftY() {
        return updateAnalogTimer(1, 0f, _left.y);        
    }

    /// Returns the left stick x and y axis as a button.
    bool getControllerInputSingleLeftXY() {
        return updateAnalogTimer(2, _left.x, _left.y);        
    }

    /// Returns the right stick x-axis as a button.
    bool getControllerInputSingleRightX() {
        return updateAnalogTimer(3, _right.x, 0f);
    }

    /// Returns the right stick y-axis as a button.
    bool getControllerInputSingleRightY() {
        return updateAnalogTimer(4, 0f, _right.y);        
    }

    /// Returns the right stick x and y axis as a button.
    bool getControllerInputSingleRightXY() {
        return updateAnalogTimer(5, _right.x, _right.y);        
    }
}