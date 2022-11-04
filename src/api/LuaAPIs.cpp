#include "AppletEventAPI.cpp"

static const luaL_Reg libs[] = {
  {"AppletEvents", Kitsune::API::AppletEvents::LuaOpen},
  {NULL, NULL}
};

void IncludeLuaAPIs(lua_State *L) {
  for (int i = 0; libs[i].name; i++) {
    luaL_requiref(L, libs[i].name, libs[i].func, 1);
  }
}