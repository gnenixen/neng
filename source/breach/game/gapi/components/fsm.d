module game.gapi.components.fsm;

public:
import engine.core.templates;

import game.core.actions;
import game.core.components.fsm;
import game.core.character;

import game.gapi.components.controller;
import game.gapi.commands;

class CGAPICharacterState : CState {
    mixin( TRegisterClass!CGAPICharacterState );
protected:
    bool bLockDirection;

    SMovementConfig moveCfg;
    SMovementConfig _moveCfg;

    String enterAnimation;

    bool _bLockDirection;

public:
    this() {
        super();
        bLockDirection = false;
    }

    void _enter() {}
    void _leave() {}
    void _ptick( float delta ) {}
    void _tick( float delta ) {}
    void _input( CInputAction action ) {}

    override void enter() {
        _bLockDirection = character.bLockDirection;
        _moveCfg = movement.cfg;
        moveCfg = movement.cfg;

        _enter();

        if ( enterAnimation != "" ) {
            animation.play( enterAnimation, 0, true );
        }

        character.bLockDirection = bLockDirection;
        movement.cfg = moveCfg;
    }

    override void leave() {
        _leave();

        character.bLockDirection = _bLockDirection;
        movement.cfg = _moveCfg;
    }

    override void ptick( float delta ) {
        _ptick( delta );
    }

    override void tick( float delta ) {
        _tick( delta );
    }

    override void input( CInputAction action ) {
        _input( action );
    }

    void _handle( CCharacterControllerCommand command ) {}

protected:
    CGAPICharacter character() { return Cast!CGAPICharacter( owner.object ); }
    CMovementComponent movement() { return character.movement; }
    CSpinePlayer animation() { return character.animation; }

    SVec2F velocity() { return movement.velocity; }
    CTimer execLater( float time, void delegate() del ) { return character.timer.execLater( time, del ); }
}
