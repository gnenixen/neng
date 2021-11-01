module editor.base;

public:
import engine.core.object;
import engine.core.containers.array;

class CBaseEditor : CObject {
    mixin( TRegisterClass!CBaseEditor );
public:
    bool bVisible = true;

public:
    void update( float delta ) {}
    void draw() {}
}

class CGEditor : CObject {
    mixin( TRegisterClass!( CGEditor, Singleton ) );
protected:
    Array!CBaseEditor editors;

public:
    void draw() {
        foreach ( editor; editors ) {
            if ( editor.bVisible ) {
                editor.draw();
            }
        }
    }
}

pragma( inline, true )
CGEditor GEditor() { return CGEditor.sig; }
