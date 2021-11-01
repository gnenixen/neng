module game.core.components.stamina;

import game.core.base.component;

class CStaminaComponent : CComponent {
    mixin( TRegisterClass!CStaminaComponent );
public:
    Signal!( uint ) currentUpdated;

public:
    bool bRegenerate = true;

    float regenerateStepTime = 0.1f;
    uint regeneratePerStep = 1;

protected:
    int lcurrent = 12;
    int lmax = 12;

    float lregenerateStepTimeCurrent = 0.0f;

public:
    this() {
        lregenerateStepTimeCurrent = regenerateStepTime;
    }

    override void _tick( float delta ) {
        if ( lcurrent == lmax || !bRegenerate ) {
            lregenerateStepTimeCurrent = regenerateStepTime;
        }

        lregenerateStepTimeCurrent -= delta;
        
        if ( lregenerateStepTimeCurrent <= 0.0f && lcurrent < lmax ) {
            lregenerateStepTimeCurrent = regenerateStepTime;

            lcurrent = Math.min( lmax, lcurrent + regeneratePerStep );
            currentUpdated.emit( lcurrent );
        }
    }
    
    bool isCanMin( int val ) {
        return lcurrent - val >= 0;
    }

    bool min( int val, bool bAllowLowerThanNull = true ) {
        if ( !isCanMin( val ) && !bAllowLowerThanNull ) return false;

        lcurrent = Math.max( lcurrent - val, 0 );
        currentUpdated.emit( lcurrent );

        lregenerateStepTimeCurrent = 1.5f;

        return true;
    }

    float percent() {
        return lcurrent / cast( float )lmax * 100.0f;
    }

public:
    @property {
        int current() { return lcurrent; }
        int max() { return lmax; }

        void current( int val ) {
            assert( false );
        }

        void max( int imax ) {
            assert( imax > 0 );

            lmax = imax;
            
            if ( lcurrent > lmax ) {
                lcurrent = lmax;
            }
        }
    }
}
