module engine.core.signal;

import std.signals : _d_toObject, rt_attachDisposeEvent, rt_detachDisposeEvent;

import engine.core.containers.array;
import engine.core.memory;

struct SSignal( T1... ) {
    /***
        A slot is implemented as a delegate.
        The Slot is the type of the delegate.
        The delegate must be to an instance of a class or an interface
        to a class instance.
        Delegates to struct instances or nested functions must not be
        used as slots.
    */
    alias Slot = void delegate(T1);

    /***
        There can be multiple destructors inserted by mixins.
    */
    ~this() {
        /***
            When this object is destroyed, need to let every slot
            know that this object is destroyed so they are not left
            with dangling references to it.
        */
        if ( slots.length ) {
            foreach ( slot; slots ) {
                if ( slot ) {
                    Object o = _d_toObject( slot.ptr );
                    rt_detachDisposeEvent( o, &unhook );
                }
            }
        }

        slots.free();
    }

    /***
        Call each of the connected slots, passing the argument(s) i to them.
        Nested call will be ignored.
    */
    final void emit( T1 i ) {
        if ( status >= ST.inemitting || !slots.length ) {
            return; // should not nest
        }

        status = ST.inemitting;
        scope( exit ) status = ST.idle;

        foreach ( slot; slots ) {  
            if ( slot ) {
                slot( i );
            }
        }

        assert( status >= ST.inemitting );
        if ( status == ST.inemitting_disconnected ) {
            for ( size_t j = 0; j < slots_idx; ) {
                if ( slots[j] is null ) {
                    slots_idx--;
                    slots[j] = slots[slots_idx];
                } else {
                    j++;
                }
            }
        }
    }

    /***
        Add a slot to the list of slots to be called when emit() is called.
    */
    final void connect( Slot slot ) {
        slots ~= slot;
        slots_idx++;

        Object o = _d_toObject( slot.ptr );
        rt_attachDisposeEvent( o, &unhook );
    }

    /***
        Remove a slot from the list of slots to be called when emit() is called.
    */
    final void disconnect( Slot slot ) {
        size_t disconnectedSlots = 0;
        size_t instancePreviousSlots = 0;
        
        if ( status >= ST.inemitting ) {
            foreach ( i, sloti; slots ) {
                if ( sloti.ptr == slot.ptr &&
                    ++instancePreviousSlots &&
                    sloti == slot )
                {
                    disconnectedSlots++;
                    slots[i] = null;
                    status = ST.inemitting_disconnected;
                }
            }
        } else {
            for ( size_t i = 0; i < slots_idx; ) {
                if ( slots[i].ptr == slot.ptr &&
                    ++instancePreviousSlots &&
                    slots[i] == slot )
                {
                    slots_idx--;
                    disconnectedSlots++;
                    slots[i] = slots[slots_idx];
                    slots[slots_idx] = null;        // not strictly necessary
                } else {
                    i++;
                }
            }
        }

        // detach object from dispose event if all its slots have been removed
        if ( instancePreviousSlots == disconnectedSlots ) {
            Object o = _d_toObject( slot.ptr );
            rt_detachDisposeEvent( o, &unhook );
        }
     }

    /***
        Disconnect all the slots.
    */
    final void disconnectAll() {
        this.destroy();
        slots_idx = 0;
        status = ST.idle;
    }

    /***
        Special function called when o is destroyed.
        It causes any slots dependent on o to be removed from the list
        of slots to be called by emit().
    */
    final void unhook( Object o )
    in { assert( status == ST.idle ); }
    do {
        for ( size_t i = 0; i < slots_idx; ) {
            if ( _d_toObject( slots[i].ptr ) is o ) {
                slots_idx--;
                slots[i] = slots[slots_idx];
                slots[slots_idx] = null;        // not strictly necessary
            } else {
                i++;
            }
        }
    }

private:
    Array!( Slot, 1 ) slots;
    size_t slots_idx;           // used length of slots[]

    enum ST { idle, inemitting, inemitting_disconnected }
    ST status;
}

alias Signal = SSignal;