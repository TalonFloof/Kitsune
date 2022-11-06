#include <string>
#include <unordered_map>
#include <vector>

namespace Kitsune::API::Renderer {
    static std::unordered_map<std::string, SDL_Surface*> TextureRegistry;
    static std::vector<SDL_Rect> ClipStack;

    int ClearScreen(lua_State* L) {
        int r,g,b,a;
        r = luaL_checknumber(L, 1);
        g = luaL_checknumber(L, 2);
        b = luaL_checknumber(L, 3);
        a = luaL_checknumber(L, 4);
        SDL_SetRenderDrawColor(Kitsune::Applet::appletRenderer, r, g, b, a);
        SDL_RenderClear(Kitsune::Applet::appletRenderer);
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
        return 0;
    }
    int PushClipArea(lua_State* L) {
        SDL_Rect area;
        if(SDL_RenderIsClipEnabled(Kitsune::Applet::appletRenderer)) {
            SDL_RenderGetClipRect(Kitsune::Applet::appletRenderer,&area);
            ClipStack.push_back(area);
        }
        area.x = luaL_checknumber(L, 1);
        area.y = luaL_checknumber(L, 2);
        area.w = luaL_checknumber(L, 3);
        area.h = luaL_checknumber(L, 4);
        SDL_RenderSetClipRect(Kitsune::Applet::appletRenderer, &area);
        return 0;
    }
    int PopClipArea(lua_State* L) {
        if(SDL_RenderIsClipEnabled(Kitsune::Applet::appletRenderer)) {
            if(ClipStack.empty()) {
                SDL_RenderSetClipRect(Kitsune::Applet::appletRenderer, NULL);
            } else {
                SDL_RenderSetClipRect(Kitsune::Applet::appletRenderer, &ClipStack.back());
                ClipStack.pop_back();
            }
        }
        return 0;
    }
    int ClearClipStack(lua_State* L) {
        SDL_RenderSetClipRect(Kitsune::Applet::appletRenderer, NULL);
        ClipStack.clear();
        return 0;
    }
    int LoadImage(lua_State* L) {
        std::string name = std::string(luaL_checkstring(L, 1));
        SDL_Surface* image = IMG_Load(luaL_checkstring(L, 2));
        if(image == NULL) {
            lua_pushboolean(L,0);
        } else {
            TextureRegistry[name] = image;
            lua_pushboolean(L,1);
        }
        return 1;
    }
    int DrawImage(lua_State* L) {
        std::string name = std::string(luaL_checkstring(L, 1));
        if(TextureRegistry.find(name) != TextureRegistry.end()) {
            SDL_Rect dst;
            dst.x = luaL_checknumber(L, 2);
            dst.y = luaL_checknumber(L, 3);
            dst.w = luaL_checknumber(L, 4);
            dst.h = luaL_checknumber(L, 5);
            SDL_Texture* tex = SDL_CreateTextureFromSurface(Kitsune::Applet::appletRenderer,TextureRegistry[name]);
            SDL_SetTextureScaleMode(tex,SDL_ScaleModeLinear);
            SDL_RenderCopy(Kitsune::Applet::appletRenderer, tex, NULL, &dst);
            SDL_DestroyTexture(tex);
        }
        return 0;
    }
    int CloseImage(lua_State* L) {
        std::string name = std::string(luaL_checkstring(L, 1));
        if(TextureRegistry.find(name) != TextureRegistry.end()) { 
            SDL_FreeSurface(TextureRegistry[name]);
            delete TextureRegistry[name];
        }
        return 0;
    }
    int Invalidate(lua_State* L) {
        SDL_RenderPresent(Kitsune::Applet::appletRenderer);
        return 0;
    }

    static const luaL_Reg lib[] = {
        {"Clear", ClearScreen},
        {"Rect", DrawRect},
        {"Text", DrawText},
        {"LoadImage", LoadImage},
        {"Image", DrawImage},
        {"CloseImage", CloseImage},
        {"PushClipArea", PushClipArea},
        {"PopClipArea", PopClipArea},
        {"ClearClipStack", ClearClipStack},
        {"Invalidate", Invalidate},
        {NULL, NULL}
    };

    static int LuaOpen(lua_State *L) {
        luaL_newlib(L, lib);
        return 1;
    }
}