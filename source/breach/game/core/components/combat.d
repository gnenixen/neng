module game.core.components.combat;

import engine.core.signal;
import engine.modules.physics_2d;

import game.core.base.component;
import game.core.character;
import game.core.components.physics;

enum ESingleAttackType {
    NONE,
    LIGHT,
    HEAVY,
}

struct SAttackDescription {
    ESingleAttackType type;
    bool bCombo = false;

    uint damage;

    CGameObject from;
    CGameObject to;
}

class CCombo : CObject {
    mixin( TRegisterClass!CCombo );
public:
    Array!ESingleAttackType keys() { return Array!ESingleAttackType(); }

    Array!CGameObject query( CCombatComponent from, SVec2I direction ) { return Array!CGameObject(); }

    void applyEffect( CCombatComponent from, CGameObject obj ) {}
}

class CTripleLigthCombo : CCombo {
    mixin( TRegisterClass!CTripleLigthCombo );
public:
    override Array!ESingleAttackType keys() { 
        return Array!ESingleAttackType(
            ESingleAttackType.LIGHT,
            ESingleAttackType.LIGHT,
            ESingleAttackType.LIGHT,
        );
    }

    override Array!CGameObject query( CCombatComponent from, SVec2I direction ) {
        SAttackDescription description = from.createAttackDescription( ESingleAttackType.LIGHT, direction );
        if ( description.to ) {
            return Array!CGameObject( description.to );
        }

        return Array!CGameObject();
    }

    override void applyEffect( CCombatComponent from, CGameObject obj ) {
        import game.gapi.effects;

        CBaseCharacter _from = Cast!CBaseCharacter( from.object );
        CEffectsComponent effects = obj.getComponent!CEffectsComponent();

        if ( effects && _from ) {
            effects.add( NewObject!CTESTBlockEffect() );
            effects.add( NewObject!CTESTSlideEffect( _from.direction ) );
        }
    }

}

struct SAttacksBuffer {
    Array!ESingleAttackType buffer;

    alias buffer this;

    void reset() {
        foreach ( i; 0..buffer.length - 1 ) {
            buffer[i] = ESingleAttackType.NONE;
        }
    }

    void append( ESingleAttackType type ) {
        long idx = -1;
        foreach ( i; 0..buffer.length - 1 ) {
            if ( buffer[i] == ESingleAttackType.NONE ) {
                idx = i;
                break;
            }
        }

        if ( idx == -1 ) {
            shift();
            idx = buffer.length - 1;
        }

        buffer[idx] = type;
    }

    void shift() {
        foreach ( i; 1..buffer.length - 1 ) {
            buffer[i - 1] = buffer[i];
        }

        buffer[$ - 1] = ESingleAttackType.NONE;
    }
}

class CCombatComponent : CComponent {
    mixin( TRegisterClass!CCombatComponent );
public:
    Signal!() onHit;
    Signal!() onComboCast;
    Signal!() onComboHit;

public:
    float distance;

private:
    CPhysicsComponent physics;

    SAttacksBuffer buffer;
    Array!CCombo combos;

public:
    this() {
        distance = 128;
        buffer.resize( 5 );

        combos ~= NewObject!CTripleLigthCombo();
    }

    ~this() {
        onHit.disconnectAll();
        onComboCast.disconnectAll();
        onComboHit.disconnectAll();
    }
    
    override void _begin() {
        physics = object.getComponent!CPhysicsComponent();
        assert( physics );
    }

    void attack( ESingleAttackType type, SVec2I direction ) {
        SAttackDescription description = createAttackDescription( type, direction );

        buffer.append( type );

        if ( description.to !is null ) {
            CCombatComponent combat = description.to.getComponent!CCombatComponent();
            if ( combat ) {
                onHit.emit();
                combat.takeDamage( description );
            }
        }

        CCombo combo = getComboFromAttackBuffer();
        if ( combo ) {
            onComboCast.emit();
            buffer.reset();

            Array!CGameObject hitted = combo.query( this, direction );
            if ( hitted.length ) onComboHit.emit();

            foreach ( obj; hitted ) {
                combo.applyEffect( this, obj );
            }
        }
    }

    void takeDamage( SAttackDescription description ) {
        CHealthCompnent health = object.getComponent!CHealthCompnent();
        if ( health ) {
            health.damage( description.damage );
        }
    }

    void reset() {
        buffer.reset();
    }

    SAttackDescription createAttackDescription( ESingleAttackType type, SVec2I direction ) {
        SAttackDescription description;
        description.type = type;
        description.bCombo = false;
        description.damage = 20;
        description.from = object;

        SP2DRayCastResult ray = raycast( direction );
        CGameObject robject = GetObjectByID!CGameObject( ray.body );
        if ( robject ) {
            description.to = robject;
        }

        return description;
    }

    SP2DRayCastResult raycast( SVec2I direction ) {
        uint mask = physics.filterData.category;

        SP2DFilterData filter;
        filter.mask = 0xFFFF & ~mask;

        return GPhysics2D.raycast(
            object.transform.pos + SVec2F( -(distance / 4), 0 ) * direction.tov!float,
            object.transform.pos + SVec2F( distance, 0 ) * direction.tov!float,
            filter
        );
    }

private:
    CCombo getComboFromAttackBuffer() {
        ulong idx = -1;
        foreach ( i; 0..buffer.buffer.length - 1 ) {
            if ( buffer.buffer[i] == ESingleAttackType.NONE ) {
                idx = i;
                break;
            }
        }

        if ( idx == -1 ) {
            idx = buffer.buffer.length - 1;
        }

        foreach ( combo; combos ) {
            Array!ESingleAttackType keys = combo.keys;
            if ( keys.length > idx + 1 ) continue;

            bool bKeyInvalid = false;
            foreach ( i, key; keys ) {
                size_t checkId = idx - keys.length + i;
                if ( buffer.buffer[i] != key ) {
                    bKeyInvalid = true;
                    break;
                }
            }

            if ( bKeyInvalid ) continue;

            return combo;
        }

        return null;
    }
}
