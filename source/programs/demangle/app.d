import std.stdio;

import std.demangle;

void main( string[] args ) {
	assert( args.length == 2 );
	
	writeln( demangle( args[1] ) );
}
