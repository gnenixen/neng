module game.core.state;

public:
import engine.framework.fsm;
import engine.framework.input;
import engine.framework.render;

class CGameState : AState {
    mixin( TRegisterClass!CGameState );
public:
    this() { super(); }

    void ptick( float delta ) {}
    void psync() {}
    void tick( float delta ) {}
    void input( CInputAction action ) {}
    CR2D_View render( SVec2I resolution, float delta ) { return null; }
}
