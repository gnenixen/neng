module engine.core.containers.stack;

import engine.core.containers.slist;

alias Stack = SStack;

struct SStack( T ) {
private:
    SList!T lelements;

public:
    void push( T elem ) {
        lelements.insertFront( elem );
    }

    T pop() {
        T value;
        
        if ( lelements.length > 0 ) {
            value = lelements.head.data;
            lelements.removeFront();
        }

        return value;
    }

    size_t length() {
        return lelements.length;
    }

    bool isEmpty() { return length == 0; }

    void free() {
        lelements.free();
    }
}
