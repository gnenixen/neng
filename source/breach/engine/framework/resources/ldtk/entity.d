module engine.framework.resources.ldtk.entity;

import engine.core.object;
import engine.core.math;

import engine.framework.resources.ldtk.entity_def;
import engine.framework.resources.ldtk.fields_container;

class CLDTKEntity : CLDTKFieldsContainer {
    mixin( TRegisterClass!CLDTKEntity );
private:
    CLDTKEntityDef definition;

    SVec2I size;
    SVec2I position;
    SVec2I gridPos;
}
