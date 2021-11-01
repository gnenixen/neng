module editor;

public:
import editor.base;

void initializeEditor() {
    import engine.core : GSymbolDB;

    GSymbolDB.register!CGEditor;
}

