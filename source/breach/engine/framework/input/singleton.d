module engine.framework.input.singleton;

import engine.core.object;
import engine.core.input;
import engine.core.log;

import engine.framework.input.action;

class CInput : CObject {
    mixin( TRegisterClass!( CInput, Singleton ) );
public:
    CIKeyboard keyboard;
    CIMouse mouse;

protected:
    Array!ID devices;
    Array!AInputEvent events;
    Dict!( CInputAction, String ) actions;

    Array!CInputAction currentFrameActions;

public:
    this() {
        devices = GInputBackend.devices();

        keyboard = getObjectByID!CIKeyboard( devices[0] );
        mouse = getObjectByID!CIMouse( devices[1] );
    }

    void update() {
        currentFrameActions.free();

        events = GInputBackend.queue();

        foreach ( name, action; actions )
        foreach ( ev; events ) {
            parse( action, ev );
        }
    }

    Array!CInputAction frameActions() { return currentFrameActions; }
    Array!AInputEvent frameEvents() { return events; }

    void action_add( String name, EInputActionType type ) {
        CInputAction action = newObject!CInputAction();
        action.name = name;
        action.type = type;

        actions.set( name, action );
    }

    void action_remove( String name ) {}

    void action_addEvent( String name, AInputEvent event ) {
        CInputAction action = actions.get( name, null );
        if ( !action ) {
            return;
        }

        action.events ~= event;
    }

    void action_removeEvent( String name, AInputEvent event ) {}

    float action_getStrength( String name ) {
        CInputAction action = actions.get( name, null );
        if ( !action ) {
            return 0.0f;
        }

        return action.value;
    }

    bool isActionPressed( String name ) {
        CInputAction action = actions.get( name, null );
        if ( !action ) {
            return false;
        }

        return action.value == 1.0f;
    }

    bool isActionReleased( String name ) {
        return !isActionPressed( name );
    }

private:
    void parse( CInputAction action, AInputEvent event ) {
        foreach ( ev; action.events ) {
            if ( ev.cmpImpl( event ) ) {
                action.value = event.strength();

                currentFrameActions.appendUnique( action );
            }
        }
    }
}

static __gshared pragma( inline, true ) {
    CInput GInput() { return CInput.sig; }
}
