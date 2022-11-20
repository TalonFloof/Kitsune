#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>

namespace Kitsune::API::System {
    int ListDirectory(lua_State* L) {
        const char *path = luaL_checkstring(L, 1);
        DIR *dir = opendir(path);
        if (!dir) {
            lua_pushnil(L);
            lua_pushstring(L, strerror(errno));
            return 2;
        }
        lua_newtable(L);
        int i = 1;
        struct dirent *entry;
        while ( (entry = readdir(dir)) ) {
            if (strcmp(entry->d_name, ".") == 0) { continue; }
            if (strcmp(entry->d_name, "..") == 0) { continue; }
            lua_pushstring(L, entry->d_name);
            lua_rawseti(L, -2, i);
            i++;
        }
        closedir(dir);
        return 1;
    }
    int ChangeCurrentWorkingDirectory(lua_State *L) {
        const char *path = luaL_checkstring(L, 1);
        int err = chdir(path);
        if (err) { luaL_error(L, "Failed to change Current Working Directory"); }
        return 0;
    }
    int GetFileInformation(lua_State* L) {
        const char *path = luaL_checkstring(L, 1);
        struct stat s;
        int err = stat(path, &s);
        if (err < 0) {
            lua_pushnil(L);
            lua_pushstring(L, strerror(errno));
            return 2;
        }
        lua_newtable(L);

        if (S_ISREG(s.st_mode)) {
            lua_pushstring(L, "file");
        } else if (S_ISDIR(s.st_mode)) {
            lua_pushstring(L, "dir");
        } else {
            lua_pushnil(L);
        }
        lua_setfield(L, -2, "type");
        return 1;
    }
    static int CreatePipe(lua_State* L) {
        luaL_Stream inpipe;
        luaL_Stream outpipe;
        int fd[2];
        pipe2(&fd,O_NONBLOCK | O_CLOEXEC);

    }
    int ClosePipe(lua_State* L) {
        luaL_Stream* stream;
        
        lua_pushboolean(1);
        return 1;
    }

    static const luaL_Reg lib[] = {
        {"ListDirectory", ListDirectory},
        {"ChangeCurrentWorkingDirectory",ChangeCurrentWorkingDirectory},
        {"GetFileInformation", GetFileInformation},
        {"CreatePipe", CreatePipe}
        {NULL, NULL}
    };

    static int LuaOpen(lua_State *L) {
        luaL_newlib(L, lib);
        return 1;
    }
}
