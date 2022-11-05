extern "C" {
    #include <lua.h>
    #include <lauxlib.h>
    #include <lualib.h>
}

void IncludeLuaAPIs(lua_State *);

namespace Kitsune {
    class KitsuneLuaCore {
        public:
            lua_State* curLuaState;
            KitsuneLuaCore() {
                this->curLuaState = luaL_newstate();
                luaL_openlibs(this->curLuaState);
                IncludeLuaAPIs(this->curLuaState);

                lua_pushstring(this->curLuaState, executablePath);
                lua_setglobal(this->curLuaState, "EXEC_FILE");
            }
            void runKitsuneCore() {
                (void)luaL_dostring(this->curLuaState,
                "xpcall(function()\n"
                "EXEC_DIR = EXEC_FILE:match(\"^(.+)[/\\\\].*$\")\n"
                "package.path = EXEC_DIR .. '/data/?.lua;' .. package.path\n"
                "package.path = EXEC_DIR .. '/data/?/init.lua;' .. package.path\n"
                "local kitsune = require('Kitsune')\n"
                "kitsune.Initialize()\n"
                "kitsune.Run()\n"
                "end, function(e)\n"
                "print('Kitsune ERROR: ' .. tostring(e))\n"
                "print(debug.traceback(nil, 2))\n"
                "os.exit(1)\n"
                "end)");
            }
    };
};