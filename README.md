# NENG
Modular D game engine.

### Information
Home made game engine with no editor, because in current time it's really hard to me to develope it.

Realize some regular stuff, like: 2d physics, render device, sound, Behaviour trees, FSM, AStar pathfinding, tilemaps(dirty code), LDTK, thread pools and other.

You can use any part of this code as you want, just add liks to me, nothing more.

For any information about systems and architecture of engine please write to my email: gfabricin@gmail.com

### Building
For building you need SCons build system, python and some regular libs on linux distro, like GLX, MESA-dev, X11-dev.
Type for building:

```
scons -j<number of thread to run>
```
  
Type for clear bulding: (means remove old build cache and build new instance of engine)
 
```
scons -c=true
```
