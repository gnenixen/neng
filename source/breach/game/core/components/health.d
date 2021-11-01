module game.core.components.health;

import game.core.base.component;

class CHealthCompnent : CComponent {
    mixin( TRegisterClass!CHealthCompnent );
public:
    Signal!() damaged;
    Signal!() damagedUnderDamageResist;
    Signal!() healed;
    Signal!( uint ) hpUpdated;
    Signal!() die;

public:
    bool bDamageResist = false;

private:
    uint lmax;
    uint lcurrent;

public:
    this( uint imax, uint icurrent ) {
        lmax = imax;
        lcurrent = icurrent;
    }

    void damage( uint value ) {
        if ( lcurrent == 0 ) return;

        if ( bDamageResist ) {
            damagedUnderDamageResist.emit();
            return;
        }

        // Must be >= 0, then pick minimal value
        lcurrent -= Math.min( value, lcurrent );

        hpUpdated.emit( lcurrent );
        damaged.emit();

        if ( lcurrent == 0 ) die.emit();
    }

    void heal( uint value ) {
        if ( lcurrent == lmax ) return;

        lcurrent += value;

        if ( lcurrent > lmax ) {
            lcurrent = lmax;
        }

        hpUpdated.emit( lcurrent );
        healed.emit();
    }

    void kill() {
        lcurrent = 0;
        hpUpdated.emit( lcurrent );
        die.emit();
    }

    float percent() { return lcurrent / cast( float )lmax * 100.0f; }

public:
    @property {
        uint max() { return lmax; }
        uint current() { return lcurrent; }

        void max( uint value ) {
            assert( value > 0 );

            if ( value < lcurrent ) {
                lcurrent = value;
            }

            lmax = value;
        }

        void current( uint value ) {
            assert( false, "Canno't set current hp directly" );
        }
    }
}

