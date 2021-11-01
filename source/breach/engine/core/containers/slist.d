module engine.core.containers.slist;

import engine.core.memory;
import engine.core.containers.array;

alias SList = SSList;
alias SListNode = SSListNode;

struct SSListNode( T ) {
    SListNode!T* next = null;
    T data;

    this( SListNode!T* inext ) {
        next = inext;
        data = T.init;
    }

    @disable this( this );

    this( ref return scope typeof( this ) other ) {
        this = other;
    }
}

struct SSList( T ) {
    alias NodeA = SListNode!T;
    alias Node = SListNode!T*;

    Node head = null;
    Node tail = null;
    size_t length = 0;

    @disable this( this );

    this( ref return scope typeof( this ) other ) {
        this = other;
    }

    void free( void function( T ) FREE = null ) {
        Node n = head;
        while ( n !is null ) {
            auto e = n;
            n = n.next;
            if ( FREE ) {
                FREE( e.data );
            }
            deallocate( e );
        }

        head = null;
        tail = null;
        length = 0;
    } 

    int opApply( scope int delegate( size_t, ref T ) dg ) {
        int result = 0;
        uint idx = 0;

        Node n = head;
        while ( n !is null ) {
            result = dg( idx, n.data );
            if ( result ) {
                break;
            }

            n = n.next;
            idx++;
        }

        return result;
    }

    Node insertBack( T val ) {
        length++;

        if ( tail is null ) {
            tail = allocate!NodeA( null );
            tail.data = val;
        } else {
            tail.next = allocate!NodeA( null );
            tail.next.data = val;
            tail = tail.next;
        }

        if ( head is null ) {
            head = tail;
        }

        return tail;
    }

    auto opCatAssign( T val ) {
        insertBack( val );
        return this;
    }

    Node insertAfter( Node node, T val ) {
        length++;
        
        Node newNode = allocate!NodeA( null );
        newNode.data = val;
        newNode.next = node.next;
        node.next = newNode;

        if ( node is tail ) {
            tail = newNode;
        }

        return newNode;
    }

    Node insertFront( T val ) {
        length++;

        Node newNode = allocate!NodeA( null );
        newNode.data = val;
        newNode.next = head;
        head = newNode;

        if ( tail is null ) {
            tail = head;
        }

        return newNode;
    }

    void removeAfter( Node node ) {
        length--;

        Node obsolete = node.next;
        if ( obsolete !is null ) {
            if ( obsolete is tail ) {
                tail = node;
            }

            node.next = obsolete.next;
            deallocate( obsolete );
        }
    }

    void removeFront() {
        length--;

        Node obsolete = head;
        if ( obsolete !is null ) {
            head = obsolete.next;
            deallocate( obsolete );
        }
    }

    void appendList( SSList!T list ) {
        length += list.length;

        if ( tail !is null ) {
            tail.next = list.head;
        }

        if ( head is null ) {
            head = list.head;
        }

        tail = list.tail;
    }

    Array!T toArray() {
        Array!T ret;
        ret.reserve( length );
        foreach ( i, v; this ) {
            ret ~= v;
        }

        return ret;
    }

    alias append = insertBack;
}
