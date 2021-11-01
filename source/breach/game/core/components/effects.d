module game.core.components.effects;

import game.core.base.component;

class CEffect : CObject {
    mixin( TRegisterClass!CEffect );
public:
    // Time duration of the effect int seconds
    float duration = 0.0f;

    // Duration is increased each time the effect is applied
    bool bIsDurationStacked = false;

    // Effect value is increased each itme the effect is applied
    bool bIsEffectStacked = false;

    bool bFinished = false;
    CGameObject object = null;
    CEffectsComponent component = null;

protected:
    float lduration = 0.0f;
    int stacks = 0;

public:
    this( float duration ) {
        this.duration = duration;
    }

    void update( float delta ) {
        if ( bFinished ) return;
        
        lduration -= delta;
        if ( lduration <= 0 ) {
            end();
            bFinished = true;
        } else {
            tick( delta );
        }
    }

    void activate() {
        if ( bIsEffectStacked || lduration <= 0 ) {
            apply();
            stacks++;
        }

        if ( bIsDurationStacked || lduration <= 0 ) {
            lduration = duration;
        }
    }

    void apply() {}
    void tick( float delta ) {}
    void end() {}
}

class CEffectsComponent : CComponent {
    mixin( TRegisterClass!CEffectsComponent );
private:
    Array!CEffect effects;

public:
    override void _tick( float delta ) {
        foreach ( effect; effects ) {
            effect.update( delta );

            if ( effect.bFinished ) {
                effects.remove( effect );
            }
        }
    }

    void add( CEffect effect ) {
        foreach ( eff; effects ) {
            if ( effect.typename == eff.typename ) {
                eff.activate();
                destroyObject( effect );
                return;
            }
        }

        effects ~= effect;
        effect.object = object;
        effect.component = this;
        effect.activate();
    }

    bool has( T )()
    if ( is( T : CEffect ) ) {
        foreach ( eff; effects ) {
            if ( Cast!T( eff ) ) {
                return true;
            }
        }

        return false;
    }
}
