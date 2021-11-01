#!/usr/bin/env python

import glob
import os
import pickle
import sys
import platform as plt
import shutil

import methods

EnsureSConsVersion( 0, 98, 1 )

# Information about files and sources
custom_tools = ['default'];
platform_name = Platform();
debug_build = ARGUMENTS.get( "dbg", True );
verbose = ARGUMENTS.get( "verbose", False );
build_mod = ARGUMENTS.get( "mode", "debug" );
clear_buid = ARGUMENTS.get( "c", False );

source_dir = ARGUMENTS.get( 'src', "source" );
build_main_dir = ARGUMENTS.get( 'build_path', ".build_cache" );
build_engine_libs = "#" + build_main_dir + "/lib/";
build_platform_dir = build_main_dir + "/" + str( platform_name );

env_base = Environment(
    tools = custom_tools,
    PLATFORM = platform_name,
    SOURCE_DIR = source_dir
);
env_base.PrependENVPath( "PATH", os.getenv( "PATH" ) );

env_base.Copy = Copy;
env_base.build_mode = build_mod;

# Setup export env functions
methods.setup_env_class( env_base );

env_base.__class__.AVAIBLE_FILE_EXTS = [
    ".d", ".c", ".cpp", ".a", ".y"
]

env_base.__class__.IGNORE_FILE_EXTS = [
    ".h", ".txt", ".md", ".json", ".lua", ".bat", ".sh", ""
]

env = env_base.Clone();

env['OS'] = plt.system();
env['DIR'] = env.Dir( '.' ).abspath;
env['BIN_DIR'] = env['DIR']  + "/bin";
env['LIB_DIR'] = env['BIN_DIR'] + "/drivers";
env['BUILD_PLATFORM_DIR'] = env.Dir( '.' ).abspath + "/" + build_main_dir + "/" + str( platform_name );

methods.no_verbose( sys, env );

env.Append( DFLAGS = ["-L--no-as-needed", "-preview=shortenedMethods"] );

if debug_build:
    env.Append( DFLAGS = '-debug' );

    # Add symbolic info and warning will halt building
    env.Append( DFLAGS = ['-g', '-w', '-gs'] );

    if env['OS'] == 'Windows':
        env.Append( LINK = ['/DEBUG:FULL', '/PDB:.\\bin\\debug.pdb', '/PDBALTPATH:.\\debug.pdb'] );
else:
    env.Append( DFLAGS = "-release" );

if verbose:
    env.Append( DFLAGS = ["-v"] );

if clear_buid:
    shutil.rmtree( build_platform_dir );

# Setup build path
env.SConsignFile( build_platform_dir + "/.sconsign.dblite" );
env.CacheDir( build_platform_dir + "/__bin__/cache" );

Export( "env" );

# Run main build script
SConscript( "source/SCsub" );

if 'env' in locals():
    screen = sys.stdout
    # Progress reporting is not available in non-TTY environments since it
    # messes with the output (for example, when writing to a file)
    show_progress = sys.stdout.isatty()
    node_count = 0
    node_count_max = 0
    node_count_interval = 1
    node_count_fname = build_main_dir + '/.scons_node_count'

    import time, math

    class cache_progress:
        # The default is 1 GB cache and 12 hours half life
        def __init__(self, path = None, limit = 1073741824, half_life = 43200):
            self.path = path
            self.limit = limit
            self.exponent_scale = math.log(2) / half_life
            if path != None:
                screen.write('Current cache limit is ' + self.convert_size(limit) + ' (used: ' + self.convert_size(self.get_size(path)) + ')\n')
            self.delete(self.file_list())

        def __call__(self, node, *args, **kw):
            global node_count, node_count_max, node_count_interval, node_count_fname, show_progress
            if show_progress:
                # Print the progress percentage
                node_count += node_count_interval
                if (node_count_max > 0 and node_count <= node_count_max):
                    screen.write('\r[%3d%%] ' % (node_count * 100 / node_count_max))
                    screen.flush()
                elif (node_count_max > 0 and node_count > node_count_max):
                    screen.write('\r[100%] ')
                    screen.flush()
                else:
                    screen.write('\r[Initial build] ')
                    screen.flush()

        def delete(self, files):
            if len(files) == 0:
                return
            if env['verbose']:
                # Utter something
                screen.write('\rPurging %d %s from cache...\n' % (len(files), len(files) > 1 and 'files' or 'file'))
            [os.remove(f) for f in files]

        def file_list(self):
            if self.path is None:
                # Nothing to do
                return []
            # Gather a list of (filename, (size, atime)) within the
            # cache directory
            file_stat = [(x, os.stat(x)[6:8]) for x in glob.glob(os.path.join(self.path, '*', '*'))]
            if file_stat == []:
                # Nothing to do
                return []
            # Weight the cache files by size (assumed to be roughly
            # proportional to the recompilation time) times an exponential
            # decay since the ctime, and return a list with the entries
            # (filename, size, weight).
            current_time = time.time()
            file_stat = [(x[0], x[1][0], (current_time - x[1][1])) for x in file_stat]
            # Sort by the most recently accessed files (most sensible to keep) first
            file_stat.sort(key=lambda x: x[2])
            # Search for the first entry where the storage limit is
            # reached
            sum, mark = 0, None
            for i,x in enumerate(file_stat):
                sum += x[1]
                if sum > self.limit:
                    mark = i
                    break
            if mark is None:
                return []
            else:
                return [x[0] for x in file_stat[mark:]]

        def convert_size(self, size_bytes):
            if size_bytes == 0:
                return "0 bytes"
            size_name = ("bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB")
            i = int(math.floor(math.log(size_bytes, 1024)))
            p = math.pow(1024, i)
            s = round(size_bytes / p, 2)
            return "%s %s" % (int(s) if i == 0 else s, size_name[i])

        def get_size(self, start_path = '.'):
            total_size = 0
            for dirpath, dirnames, filenames in os.walk(start_path):
                for f in filenames:
                    fp = os.path.join(dirpath, f)
                    total_size += os.path.getsize(fp)
            return total_size

    def progress_finish(target, source, env):
        global node_count, progressor
        with open(node_count_fname, 'w') as f:
            f.write('%d\n' % node_count)
        progressor.delete(progressor.file_list())

    try:
        with open(node_count_fname) as f:
            node_count_max = int(f.readline())
    except:
        pass

    cache_directory = os.environ.get("SCONS_CACHE")
    # Simple cache pruning, attached to SCons' progress callback. Trim the
    # cache directory to a size not larger than cache_limit.
    cache_limit = float(os.getenv("SCONS_CACHE_LIMIT", 1024)) * 1024 * 1024
    progressor = cache_progress(cache_directory, cache_limit)
    Progress(progressor, interval = node_count_interval)

    progress_finish_command = Command('progress_finish', [], progress_finish)
    AlwaysBuild(progress_finish_command)
