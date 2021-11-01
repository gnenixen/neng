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

### Examples
2D Light with normal mapping
![2D Light](https://github.com/gnenixen/neng/blob/master/.github/images/Pictures2021-08-16_02-39-21_screenshot.png)

LDTK importer, Spine animation and ImGUI 
![LDTK importer and Spine animation](https://github.com/gnenixen/neng/blob/master/.github/images/Pictures2021-08-05_00-12-39_screenshot.png)

AStar pathfinding with custom line rendering
![AStar pathfinding with custom line rendering](https://github.com/gnenixen/neng/blob/master/.github/images/h3dhn5HK60Q.jpg)
