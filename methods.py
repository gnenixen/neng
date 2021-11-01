import os
import os.path
import re
import glob
import subprocess

from shutil import copytree
from compat import iteritems, isbasestring, decode_utf8

class CModuleBuildRules:
    def __init__( self, build_rule_name, flags ):
        self.name = build_rule_name;
        self.flags = flags;
    
    def build( self, env, path, sources, libs = [] ): pass
    def compile_src( self, env, path, sources ): pass

class CLibraryBR( CModuleBuildRules ):
    def __init__( self, flags = [] ):
        super().__init__( "library", flags );
    
    def build( self, env, path, sources, libs = [] ):
        if sources.__len__() == 0:
            return None;
        
        lib = self.__dict__.get( "lib", None );
        if lib is None:
            lib = env.Library( path, sources );
            env.NoCache( lib );
        
        return lib;
    
    def compile_src( self, env, path, sources ):
        if sources.__len__() == 0:
            return list();
        
        if sources.__len__() == 1:
            self.lib = env.Library( sources[0] );
            return list();

        ret = list();

        for src in sources:
            file_name, file_ext = os.path.splitext( src );

            if file_ext == ".a":
                continue;
            
            if file_ext == ".lib":
                continue;

            if file_ext in env.IGNORE_FILE_EXTS:
                continue;

            if file_ext not in env.AVAIBLE_FILE_EXTS:
                print( "Usupported source file type add support in SConstruct file, skip: " + src );
                continue;

            file_name += ".o";

            bf = env.Object(
                target = path + file_name.replace( env['DIR'], '' )[1:],
                source = src,
                DFLAGS = env["DFLAGS"] + ["-m64"]
            );

            ret.append( bf );

        return ret;

class CSharedLibraryBR( CModuleBuildRules ):
    def __init__( self, flags = [] ):
        super().__init__( "shared_library", flags );
    
    def build( self, env, path, sources, libs = [] ):
        return env.SharedLibrary( path, sources, LIBS = env.get("LIBS", []) + libs, DFLAGS = env["DFLAGS"] + ["-shared"] );
    
    def compile_src( self, env, path, sources ):
        if sources.__len__() == 0:
            return list();
        
        ret = list();

        for src in sources:
            file_name, file_ext = os.path.splitext( src );

            if file_ext == ".a" or file_ext == ".lib":
                continue;

            if file_ext in env.IGNORE_FILE_EXTS:
                continue;

            if file_ext not in env.AVAIBLE_FILE_EXTS:
                print( "Usupported source file type add support in SConstruct file, skip: " + src );
                continue;

            file_name += ".o";

            bf = env.SharedObject(
                target = path + file_name.replace( env['DIR'], '' )[1:],
                source = src,
                DFLAGS = env["DFLAGS"] + ["-m64"]
            );

            ret.append( bf );

        return ret;

class CProgramBR( CModuleBuildRules ):
    def __init__( self, flags = [] ):
        super().__init__( "program", flags );
    
    def build( self, env, path, sources, libs = [] ):
        _env = env.Clone();
        return _env.Program( path, sources, FLAGS = [], LIBS = _env.get("LIBS", []) + libs );
    
    def compile_src( self, env, path, sources ):
        if sources.__len__() == 0:
            return list();
        
        ret = list();

        for src in sources:
            file_name, file_ext = os.path.splitext( src );

            if file_ext == ".a" or file_ext == ".lib":
                continue;
            
            if file_ext in env.IGNORE_FILE_EXTS:
                continue;

            if file_ext not in env.AVAIBLE_FILE_EXTS:
                print( "Usupported source file type add support in SConstruct file, skip: " + src );
                continue;

            file_name += ".o";

            bf = env.Object(
                target = path + file_name.replace( env['DIR'], '' )[1:],
                source = src,
                DFLAGS = env["DFLAGS"] + ["-m64"]
            );

            ret.append( bf );

        return ret;



class CModulePass:
    def __init__( self, info ):
        self.info = info;
        self.parents = [];
        self.subs = [];

        self.bin_src = [];
        self.bin = None;
    
    def prepare_src( self, env, path ):
        if self.bin_src.__len__() != 0:
            return;

        copytree( self.info["path"], path + self.info["path"].replace( env['DIR'], '' )[1:], dirs_exist_ok = True );

        self.info["path"] = path + self.info["path"].replace( env['DIR'], '' )[1:];

        i = 0;
        for file in self.info["src"]:
            self.info["src"][i] = path + file.replace( env['DIR'], '' )[1:];
            i += 1;
        
    
    def compile_src( self, env, path, patch_source = None ):
        if self.info["cfg"]["preprocess"]:
            self.patch_sources( env, path, patch_source );

        build_rules = self.info["build_rules"];
        self.bin_src = build_rules.compile_src( env, path, self.info["src"] );

    def build( self, env, path ):
        if self.bin != None:
            return;

        libs = list();
        self.get_libs( libs );
        libs.reverse();

        build_rules = self.info["build_rules"];
        self.bin = build_rules.build( env, path + self.info["name"], self.bin_src, libs );
    
    def patch_sources( self, env, path, patch_source ):
        if patch_source == None:
            return;

        for file in self.info["src"]:
            file_name, file_ext = os.path.splitext( file );
            if file_ext != ".d":
                continue;
            
            patch_source( file );

    def get_libs( self, libs ):
        for i in self.subs:
            i.get_libs( libs );

            if isinstance( i.info["build_rules"], CLibraryBR ) and (i.bin not in libs) and (i.bin != None):
                libs.append( i.bin );
    
    def get_libs_paths( self, libs ):
        for i in self.subs:
            i.get_libs_paths( libs );

            if isinstance( i.info["build_rules"], CLibraryBR ) and (i.info["path"] not in libs):
                libs.append( i.info["path"] );

            


# ====================================
#            External use
# ====================================

def setup_env_class( env ):
    env.__class__.CLibraryBR = CLibraryBR;
    env.__class__.CSharedLibraryBR = CSharedLibraryBR;
    env.__class__.CProgramBR = CProgramBR;

    env.__class__.scsub = scsub;
    env.__class__.raw_build_program = raw_build_program;
    env.__class__.get_source_files = get_source_files;
    env.__class__.reg_module = reg_module;
    env.__class__.get_modules_folders = get_modules_folders;
    env.__class__.process_modules_declarations = process_modules_declarations;
    env.__class__.generate_modules_build_data = generate_modules_build_data;

# Recursive iterate over folder and find 
# folders, that contains SCsub files
#
# As "main_folder" arg pass name of 
# project root dir
def get_modules_folders( self, main_folder ):
    mods_folders = list();

    for subdir, dirs, files in os.walk( self.Dir( '.' ).abspath + "/" + main_folder ):
        if "SCsub" in files:
            mods_folders.append( subdir );
    
    return mods_folders;

# Process all scsub infos for generate basic
# build information, like module name, dependencies,
# source and etc...
#
# As "modules" arg pass result of function 
# "get_modules_folders" 
def process_modules_declarations( self, modules ):
    for mod in modules:
        self.SConscript( mod + "/SCsub" );

# Generate build system specific info
def generate_modules_build_data( self ):
    mods = dict();
    
    for mod in self.modules:
        mods[mod] = CModulePass( self.modules.get( mod, None ) );
    
    for mod in mods:
        fill_module_info_req( mods, mods[mod] );

    return mods;





def add_source_files(self, sources, files = "*.d", warn_duplicates=True):
    # Convert string to list of absolute paths (including expanding wildcard)
    if isbasestring(files):
        # Keep SCons project-absolute path as they are (no wildcard support)
        if files.startswith('#'):
            if '*' in files:
                print("ERROR: Wildcards can't be expanded in SCons project-absolute path: '{}'".format(files))
                return
            files = [files]
        else:
            dir_path = self.Dir('.').abspath
            files = sorted(glob.glob(dir_path + "/" + files))

    # Add each path as compiled Object following environment (self) configuration
    for path in files:
        sources.append( path );

def get_sf_req( path, srcs ):
    for subdir, dirs, files in os.walk( path ):
        if "SCsub" in files:
            return;
        
        for file in files:
            srcs.append( path + "/" + file );
        
        for d in dirs:
            get_sf_req( path + "/" + d, srcs );
        
        return;

def get_source_files( self, files = "*.d", custom_folders = [], ignore_folders = [] ):
    srcs = [];

    add_source_files( self, srcs, files );

    for subdir, dirs, files in os.walk( self.Dir( '.' ).abspath ):
        if custom_folders.__len__() != 0:
            for i in custom_folders:
                get_sf_req( subdir + "/" + i, srcs );
        else:
            for d in dirs:
                if d not in ignore_folders:
                    get_sf_req( subdir + "/" + d, srcs );
        
        break;
    
    return srcs;

# Register module in env
def reg_module( env, mod_name, mod ):
    descr = dict();

    descr["path"] = env.Dir('.').abspath;
    descr["name"] = mod_name;
    descr["src"] = mod.mod_src();
    descr["build_rules"] = mod.mod_build();
    descr["sub"] = mod.mod_sub();

    if hasattr( mod, "mod_cfg" ):
        descr["cfg"] = mod.mod_cfg();
    else:
        descr["cfg"] = {
            "preprocess": True
        };
    
    env.modules[mod_name] = descr;

def raw_build_program( env, name, sources ):
    env.Program( name, sources );

def scsub( env, path ):
    if path.endswith( "/SCsub" ):
        env.SConscript( path );
    else:
        env.SConscript( path + "/SCsub" );

def no_verbose( sys, env ):
    colors = {}

    # Colors are disabled in non-TTY environments such as pipes. This means
    # that if output is redirected to a file, it will not contain color codes
    if sys.stdout.isatty():
        colors["cyan"] = "\033[96m"
        colors["purple"] = "\033[95m"
        colors["blue"] = "\033[94m"
        colors["green"] = "\033[92m"
        colors["yellow"] = "\033[93m"
        colors["red"] = "\033[91m"
        colors["end"] = "\033[0m"
    else:
        colors["cyan"] = ""
        colors["purple"] = ""
        colors["blue"] = ""
        colors["green"] = ""
        colors["yellow"] = ""
        colors["red"] = ""
        colors["end"] = ""

    compile_source_message = "{}Compiling {}==> {}$SOURCE{}".format(
        colors["blue"], colors["purple"], colors["yellow"], colors["end"]
    )
    java_compile_source_message = "{}Compiling {}==> {}$SOURCE{}".format(
        colors["blue"], colors["purple"], colors["yellow"], colors["end"]
    )
    compile_shared_source_message = "{}Compiling shared {}==> {}$SOURCE{}".format(
        colors["blue"], colors["purple"], colors["yellow"], colors["end"]
    )
    link_program_message = "{}Linking Program        {}==> {}$TARGET{}".format(
        colors["red"], colors["purple"], colors["yellow"], colors["end"]
    )
    link_library_message = "{}Linking Static Library {}==> {}$TARGET{}".format(
        colors["red"], colors["purple"], colors["yellow"], colors["end"]
    )
    ranlib_library_message = "{}Ranlib Library         {}==> {}$TARGET{}".format(
        colors["red"], colors["purple"], colors["yellow"], colors["end"]
    )
    link_shared_library_message = "{}Linking Shared Library {}==> {}$TARGET{}".format(
        colors["red"], colors["purple"], colors["yellow"], colors["end"]
    )
    java_library_message = "{}Creating Java Archive  {}==> {}$TARGET{}".format(
        colors["red"], colors["purple"], colors["yellow"], colors["end"]
    )

    env.Append(CXXCOMSTR=[compile_source_message])
    env.Append(CCCOMSTR=[compile_source_message])
    env.Append(DCOMSTR=[compile_source_message])
    env.Append(SHCCCOMSTR=[compile_shared_source_message])
    env.Append(SHCXXCOMSTR=[compile_shared_source_message])
    env.Append(SHDCOMSTR=[compile_shared_source_message])
    env.Append(ARCOMSTR=[link_library_message])
    env.Append(RANLIBCOMSTR=[ranlib_library_message])
    env.Append(SHLINKCOMSTR=[link_shared_library_message])
    env.Append(LINKCOMSTR=[link_program_message])
    env.Append(JARCOMSTR=[java_library_message])
    env.Append(JAVACCOMSTR=[java_compile_source_message])

# ====================================
#          Internal use
# ====================================

# Recursive fill modules infos
def fill_module_info_req( mods, mod ):
    assert mod != None;

    for submod_name in mod.info["sub"]:
        submod = mods.get( submod_name, None );
        assert submod != None, "Invalid module name \"" + submod_name + "\" in module \"" + mod.info["name"] + '"';

        if mod not in submod.parents:
            submod.parents.append( mod );
        
        if submod not in mod.subs:
            mod.subs.append( submod );

        fill_module_info_req( mods, submod );
