module game.main;

import engine;
import shell;

import game.bshell;

void gameSetup() {
    CGameShell shell = newObject!CGameShell();
    CBreachGameModule mod = newObject!CBreachGameModule();
    CBreachGame game = newObject!CBreachGame();

    /*import engine.framework;
    CJSONValue root = CJSONParser.parse(
        GFileSystem.fileReadAsString( "res/data.json" )
    );
    CLDTKWorld world = newObject!CLDTKWorld( root );
    CLDTKLevel level = world.getLevel( "Entrance" );
    log.warning( level );
    foreach ( layer; level.layers ) {
        log.warning( layer.definition.name );
    }*/


    shell.run( mod, game );
}

import std.stdio;

struct STest {
    mixin( TRegisterStruct!STest );
public:
    Array!String array;
}

struct STest2 {
    mixin( TRegisterStruct!STest2 );
public:
    String handler;
}
struct STest3 {
    mixin( TRegisterStruct!STest );
public:
    Array!( Array!int ) array;
}

void stringCopyTest( String cpy ) {
    String trs;
    //writeln("RAW3: ", cpy.ldata.ldata.refcount);
    //trs.ldata = cpy.ldata.copy();
    String t = cpy;
    //writeln("RAW3: ", cpy.ldata.ldata.refcount);
    //writeln("RAW3: ", trs.ldata.ldata.refcount);
}

String stringConstructTest() {
    String ret = String("CTOR_TEST");
    return ret;
}

void test2() {
    Array!( Array!String ) arr;
    Dict!( Array!int, int ) t;
    String _str = "HI";

    t[1] = Array!int( 2000 );
    arr ~= Array!String( "Hello" );
    arr ~= Array!String( " " );
    arr ~= Array!String( "world" );
    arr ~= Array!String( "!" );


    Array!STest array;
    array ~= STest( Array!String( String("TEST"), String( "TEST2" ) ) );
    writeln( array[0].array[0] );

    STest3 test;
    test.array ~= Array!int( 10 );
    test.array ~= Array!int( 20 );
    test.array ~= Array!int( 30 );

    Array!String str;
    str ~= String("HI1");
    str ~= String("HI2");
    str ~= String("HI3");

    STest2 test2;
    test2.handler = String("HI_1");
    test2.handler = "HI_1";
    test2.handler = String("HI_1");

    String str1 = String("HI_2");
    String str2 = String( "HI@" );
    //writeln( "RAW: ", str1.ldata.ldata.refcount );
    str2 = str1;
    //writeln( "RAW: ", str1.ldata.ldata.refcount );

    String stringCpy = String("TEST_CPY");
    stringCopyTest( stringCpy );

    String ctor = stringConstructTest();

    Array!int arr1 = Array!int( 1 );
    Array!int arr2 = Array!int( 2 );
    arr1 = arr2;

    //Array!int cpy1 = Array!int( 2, 23 );
    //Array!dchar cpy2 = ctor.ldata.copy();
    //writeln( "RAW2: ", cpy2.ldata.refcount );

    //t.free();
}

void test() {
    size_t allocCount = Memory.allocationsCount;

    //log.warning( "$", Memory.allocationsCount );
    test2();

    allocCount = Memory.allocationsCount - allocCount;

    writeln( "LOCAL: ", allocCount );

}

void gameMain( string[] args ) {
    try {
        setupEngineEnv( args );

        //log.warning("MEM TEST");
        //size_t allocCount = Memory.allocationsCount;
        //CJSON json = NewObject!CJSON();

        //json.set( rs!"test", true );

        //log.warning( json.dump() );

        gameSetup();
        //test();
    //allocCount = Memory.allocationsCount - allocCount;

        //writeln( "GLOBAL: ", allocCount );

        destroyEngine();
    } catch( Exception ex ) {
        GEngine.panic( ex.msg );
    }
}
