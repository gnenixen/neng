module game.core.objects.change_level_trigger;

import engine.core.signal;
import engine.core.string;

import engine.framework.resources.ldtk;

import game.core.base._object;
import game.core.objects.base.trigger;

/*
   This trigger must be instantiated only by game state,
   because state connects to signal of this type
   and check is passed object is player.

   Do not instantiate and add on scene by yourself,
   this will not work.
*/
class CChangeLevelTrigger : CTrigger {
    mixin( TRegisterClass!CChangeLevelTrigger );
public:
    Signal!( CChangeLevelTrigger, CGameObject, String ) onGameObjectEnter;

public:
    ELDTKDir dir;

protected:
    String levelName;

public:
    this( ELDTKDir idir, String ilevelName ) {
        super();

        dir = idir;
        levelName = ilevelName;
    }

    ~this() {
        onGameObjectEnter.disconnectAll();
    }
    
    override void onObjectEnter( CGameObject obj ) {
        onGameObjectEnter.emit( this, obj, levelName );
    }
}

