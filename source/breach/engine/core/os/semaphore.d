module engine.core.os.semaphore;

import engine.core.object;

abstract class ASempahoreImpl : CObject {
    mixin( TRegisterClass!ASempahoreImpl );
public:
    abstract bool wait();
    abstract bool post();
    abstract int get();
}

alias Semaphore = ASempahoreImpl;