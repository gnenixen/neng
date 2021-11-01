module engine.core.memory.utils.raw_dlist;

import engine.core.memory.memory;

struct SRawDListNode( T ) {
    SRawDListNode!T* next = null;
    SRawDListNode!T* prev = null;

    T data;

    alias data this;
}

private struct SRawDListChunk( T ) {
    alias Node = SRawDListNode!( T );
    enum CHUNK_SIZE = 32;
    
    size_t pos = -1;
    Node*[CHUNK_SIZE] packet;

    void free() {
        foreach ( elem; packet ) {
            Memory.gallocator.deallocate( cast( void* )elem );
        }
    }

    Node* get() {
        if ( length == 0 ) {
            for ( int i = 0; i < CHUNK_SIZE; i++ ) {
                Node* n = cast( Node* )Memory.gallocator.allocate( Node.sizeof );
                n.next = null;
                n.prev = null;

                packet[i] = n;
            }

            pos = CHUNK_SIZE - 1;
        }

        return packet[pos--];
    }

    void pass( Node* node ) {
        node.next = null;
        node.prev = null;

        if ( pos < CHUNK_SIZE - 1 ) {
            pos++;
            packet[pos] = node;
        } else {
            Memory.gallocator.deallocate( cast( void* )node );
        }
    }

    size_t length() {
        return pos + 1;
    }
}

/**
    Double linked list that uses raw allocations
    Used only for handle information about allocations
*/
struct SRawDList( T ) {
    alias Node = SRawDListNode!T;

private:
    SRawDListChunk!T lchunk;

public:
    Node* head;
    Node* tail;

    size_t length = 0;

    void clear() {
        Node* n = head;
        while ( n !is null ) {
            Node* e = n;
            n = n.next;
            destroyNode( e );
        }

        head = null;
        tail = null;
        length = 0;
    }

    void free() {
        clear();
        lchunk.free();
    }

    Node* insertBack( T val ) {
        length++;

        Node* n = newNode();
        n.data = val;

        if ( tail is null ) {   // Add first element
            tail = n;
            head = tail;
        } else {                // Add all other elements
            n.prev = tail;
            tail.next = n;
            
            tail = n;
        }

        return n;
    }

    void removeAfter( Node* node ) {
        if ( node is null ) {
            return;
        }

        length--;

        Node* obsolete = node.next;
        if ( obsolete !is null ) {
            node.next = obsolete.next;

            if ( obsolete.next !is null ) {
                obsolete.next.prev = node;
            }

            //Fix tail position
            if ( obsolete is tail ) {
                tail = node;
            }

            destroyNode( obsolete );
        }
    }

    void removeCurrent( Node* node ) {
        if ( node is null ) {
            return;
        }

        length--;

        Node* prev = node.prev;
        Node* next = node.next;

        if ( prev ) {
            prev.next = next;
        }

        if ( next ) {
            next.prev = prev;
        }

        if ( node is tail ) {
            tail = prev;
        }

        destroyNode( node );
    }

    Node* getNode( T val ) {
        Node* n = head;

        while ( n !is null ) {
            if ( n.data == val ) {
                return n;
            }

            n = n.next;
        }

        return null;
    }

    Node* getNodeById( int idx ) {
        if ( head is null ) {
            return null;
        }

        Node* node = head;

        while ( idx > 0 ) {
            if ( node.next !is null ) {
                node = node.next;
            } else {
                return null;
            }
            
            idx--;
        }

        return node;
    }

    T getByIdxOr( uint idx, T defVal ) {
        if ( head is null ) {
            return defVal;
        }

        Node* node = head;

        while ( idx > 0 ) {
            if ( node.next !is null ) {
                node = node.next;
            } else {
                return defVal;
            }
            
            idx--;
        }

        return node.data;
    }

    /*T findOr( T elem, T defVal ) {
        if ( head is null ) {
            return defVal;
        }

        Node* node = head;

        while ( node != null ) {
            if ( node.data == elem ) {
                
            }
            
            node = node.next;
        }

        return defVal;
    }*/

    int opApply( scope int delegate( size_t, ref T ) dg ) {
        int result = 0;
        uint idx = 0;

        Node* n = head;
        while ( n !is null ) {
            assert( idx <= length, "Circular reference in memory manager!" );

            T data = n.data;
            result = dg( idx, data );
            if ( result ) {
                break;
            }

            n = n.next;
            idx++;
        }

        return result;
    }


private:
    Node* newNode() {
        return lchunk.get();
    }

    void destroyNode( Node* node ) {
        lchunk.pass( node );
    }
}