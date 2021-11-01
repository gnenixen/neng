module engine.core.containers.priority_queue;

import engine.core.containers.array;

struct SPriorityQueueElement( T, P ) {
    T data;
    P priority;

    alias priority this;
}

struct SPriorityQueue( T, P ) {
private:
    Array!( SPriorityQueueElement!( T, P ) ) lheap;

public:
    bool empty() { return lheap.length == 0; }

    void push( T value, P priority ) {
        lheap ~= SPriorityQueueElement!( T, P )( value, priority );

        int idx = cast(int)lheap.length - 1;
        while ( lheap[idx] > lheap[idx / 2] && idx / 2 != 0 ) {
            T temp = lheap[idx].data;
            lheap[idx].data = lheap[idx / 2].data;
            lheap[idx / 2].data = temp;
            idx = idx / 2;
        }
    }

    T pop() {
        if ( empty() ) return T.init;

        T ret = lheap[0].data;

        lheap[0] = lheap[lheap.length - 1];
        lheap.removeBack( 1 );

        int idx = 1;
        int largerChild;
        int length = cast(int)lheap.length - 1;

        while ( 2 * idx < length && (lheap[idx] < lheap[2 * idx] || lheap[idx] < lheap[2 * idx + 1]) ) {
            if ( lheap[2 * idx] > lheap[2 * idx + 1] ) {
                largerChild = 2 * idx;
            } else {
                largerChild =  2 * idx + 1;
            }

            T temp = lheap[idx].data;
            lheap[idx].data = lheap[largerChild].data;
            lheap[largerChild].data = temp;
            idx = largerChild;
        }

        return ret;
    }
}
