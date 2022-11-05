#include <unordered_map>

namespace Kitsune::API::Renderer {
    static std::unordered_map<const char*, SDL_Surface*> TextureRegistry;

    int ClearScreen(lua_State* L) {
        int r,g,b,a;
        r = luaL_checknumber(L, 1);
        g = luaL_checknumber(L, 2);
        b = luaL_checknumber(L, 3);
        a = luaL_checknumber(L, 4);
        SDL_SetRenderDrawColor(Kitsune::Applet::appletRenderer, r, g, b, a);
        SDL_RenderClear(Kitsune::Applet::appletRenderer);
        SDL_RenderPresent(Kitsune::Applet::appletRenderer);
        return 0;
    }
    int DrawRect(lua_State* L) {
        int r,g,b,a;
        SDL_Rect coords;
        coords.x = luaL_checknumber(L, 1);
        coords.y = luaL_checknumber(L, 2);
        coords.w = luaL_checknumber(L, 3);
        coords.h = luaL_checknumber(L, 4);
        r = luaL_checknumber(L, 5);
        g = luaL_checknumber(L, 6);
        b = luaL_checknumber(L, 7);
        a = luaL_checknumber(L, 8);
        SDL_SetRenderDrawColor(Kitsune::Applet::appletRenderer, r, g, b, a);
        SDL_RenderFillRect(Kitsune::Applet::appletRenderer, &coords);
        SDL_RenderPresent(Kitsune::Applet::appletRenderer);
        return 0;
    }
    void DrawGlyph(int x, int y, int scale, uint8_t glyph, int r, int g, int b) {
        SDL_Rect src, dst;
        src.x = ((int)glyph) * 8;
        src.y = 0;
        src.w = 8;
        src.h = 16;
        dst.x = x;
        dst.y = y;
        dst.w = 8*scale;
        dst.h = 16*scale;
        SDL_SetTextureColorMod(Kitsune::Applet::appletFont, r, g, b);
        SDL_RenderCopy(Kitsune::Applet::appletRenderer, Kitsune::Applet::appletFont, &src, &dst);
    }
    int DrawText(lua_State* L) {
        int x,y,scale,r,g,b;
        x = luaL_checknumber(L, 1);
        y = luaL_checknumber(L, 2);
        scale = luaL_checknumber(L, 3);
        const char *text = luaL_checkstring(L, 4);
        r = luaL_checknumber(L, 5);
        g = luaL_checknumber(L, 6);
        b = luaL_checknumber(L, 7);
        for(int i=0; i < strlen(text); i++) {
            DrawGlyph(x+(i*(8*scale)),y,scale,(uint8_t)text[i],r,g,b);
        }
        SDL_RenderPresent(Kitsune::Applet::appletRenderer);
        return 0;
    }

    static const luaL_Reg lib[] = {
        {"Clear", ClearScreen},
        {"Rect", DrawRect},
        {"Text", DrawText},
        {NULL, NULL}
    };

    static int LuaOpen(lua_State *L) {
        luaL_newlib(L, lib);
        return 1;
    }
}