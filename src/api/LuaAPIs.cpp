#include "AppletAPI.cpp"
#include "RendererAPI.cpp"
#include "SystemAPI.cpp"

static const luaL_Reg libs[] = {
  {"Applet", Kitsune::API::Applet::LuaOpen},
  {"Renderer", Kitsune::API::Renderer::LuaOpen},
  {"System", Kitsune::API::System::LuaOpen},
  {NULL, NULL}
};

void IncludeLuaAPIs(lua_State *L) {
  for (int i = 0; libs[i].name; i++) {
    luaL_requiref(L, libs[i].name, libs[i].func, 1);
  }
}