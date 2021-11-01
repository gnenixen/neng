module engine.core.containers.queue;

import engine.core.containers.slist;

alias Queue = SQueue;

struct SQueue( T ) {
private:
    SList!T lelements;

public:
    void push( T elem ) {
        lelements.insertBack( elem );
    }

    T pop() {
        T value;
        
        if ( lelements.length > 0 ) {
            auto node = lelements.head;
            value = node.data;
            lelements.removeFront();
        }

        return value;
    }

    size_t length() {
        return lelements.length;
    }

    bool isEmpty() { return length == 0; }

    void free( alias FREE = ( T elem ) {} )() {
        lelements.free!FREE();
    }
}
