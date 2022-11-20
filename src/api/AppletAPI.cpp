namespace Kitsune::API::Applet {
    char* GetKeyName(char *dst, int sym) {
        strcpy(dst, SDL_GetKeyName(sym));
        char *p = dst;
        while (*p) {
            *p = tolower(*p);
            p++;
        }
        return dst;
    }

    int PollEvent(lua_State *L) {
        char buffer[16];
        SDL_Event e;
    poll:
        if ( !SDL_PollEvent(&e) ) {
            return 0;
        }
        switch (e.type) {
            case SDL_QUIT:
                lua_pushstring(L, "AppletQuit");
                return 1;
            case SDL_WINDOWEVENT:
                if (e.window.event == SDL_WINDOWEVENT_RESIZED) {
                    lua_pushstring(L, "AppletResized");
                    lua_pushnumber(L, e.window.data1);
                    lua_pushnumber(L, e.window.data2);
                    return 3;
                /*} else if (e.window.event == SDL_WINDOWEVENT_EXPOSED) {
                    lua_pushstring(L, "AppletExposed");
                    return 1;*/
                } else if (e.window.event == SDL_WINDOWEVENT_FOCUS_GAINED) { // For compatibility
                    SDL_FlushEvent(SDL_KEYDOWN);
                }
                goto poll;
            case SDL_KEYDOWN:
                lua_pushstring(L, "AppletKeyDown");
                lua_pushstring(L, GetKeyName(buffer, e.key.keysym.sym));
                return 2;
            case SDL_KEYUP:
                lua_pushstring(L, "AppletKeyUp");
                lua_pushstring(L, GetKeyName(buffer, e.key.keysym.sym));
                return 2;
            case SDL_TEXTINPUT:
                lua_pushstring(L, "AppletText");
                lua_pushstring(L, e.text.text);
                return 2;
            case SDL_MOUSEBUTTONDOWN:
                if (e.button.button == 1) { SDL_CaptureMouse((SDL_bool)1); }
                lua_pushstring(L, "AppletMouseDown");
                lua_pushnumber(L, e.button.button);
                lua_pushnumber(L, e.button.x);
                lua_pushnumber(L, e.button.y);
                lua_pushnumber(L, e.button.clicks);
                return 5;
            case SDL_MOUSEBUTTONUP:
                if (e.button.button == 1) { SDL_CaptureMouse((SDL_bool)0); }
                lua_pushstring(L, "AppletMouseUp");
                lua_pushnumber(L, e.button.button);
                lua_pushnumber(L, e.button.x);
                lua_pushnumber(L, e.button.y);
                return 4;
            case SDL_MOUSEMOTION:
                lua_pushstring(L, "AppletMouseMoved");
                lua_pushnumber(L, e.motion.x);
                lua_pushnumber(L, e.motion.y);
                lua_pushnumber(L, e.motion.xrel);
                lua_pushnumber(L, e.motion.yrel);
                return 5;
            case SDL_MOUSEWHEEL:
                lua_pushstring(L, "AppletMouseScroll");
                lua_pushnumber(L, e.wheel.y);
                return 2;
            default:
                goto poll;
        }
        return 0;
    }

    int GetMillis(lua_State *L) {
        #if _WIN32
            lua_pushnumber(L, ((double)SDL_GetTicks())/1000);
        #else
            lua_pushnumber(L, ((double)SDL_GetTicks64())/1000);
        #endif
        return 1;
    }
    uint32_t fullscreen = 0;
    int ToggleFullscreen(lua_State *L) {
        fullscreen = fullscreen==0?SDL_WINDOW_FULLSCREEN_DESKTOP:0;
        SDL_SetWindowFullscreen(Kitsune::Applet::appletWindow, fullscreen);
        return 0;
    }
    int IsFocused(lua_State* L) {
        unsigned flags = SDL_GetWindowFlags(Kitsune::Applet::appletWindow);
        lua_pushboolean(L, flags & SDL_WINDOW_INPUT_FOCUS);
        return 1;
    }
    int GetResolution(lua_State *L) {
        int w,h;
        SDL_GetWindowSize(Kitsune::Applet::appletWindow, &w, &h);
        lua_pushnumber(L, w);
        lua_pushnumber(L, h);
        return 2;
    }

    static SDL_Cursor* CursorBuffer[SDL_SYSTEM_CURSOR_HAND + 1];

    static const char *CursorNames[] = {
        "Default",
        "Caret",
        "ResizeHorizontal",
        "ResizeVertical",
        "Hand",
        NULL
    };

    static const int CursorEnums[] = {
        SDL_SYSTEM_CURSOR_ARROW,
        SDL_SYSTEM_CURSOR_IBEAM,
        SDL_SYSTEM_CURSOR_SIZEWE,
        SDL_SYSTEM_CURSOR_SIZENS,
        SDL_SYSTEM_CURSOR_HAND
    };

    int SetCursor(lua_State *L) {
        int Option = luaL_checkoption(L, 1, "Default", CursorNames);
        int Enum = CursorEnums[Option];
        SDL_Cursor *cursor = CursorBuffer[Enum];
        if(!cursor) {
            cursor = SDL_CreateSystemCursor((SDL_SystemCursor)Enum);
            CursorBuffer[Enum] = cursor;
        }
        SDL_SetCursor(cursor);
        return 0;
    }

    int Sleep(lua_State *L) {
        double n = luaL_checknumber(L, 1);
        SDL_Delay(n * 1000);
        return 0;
    }

    static const luaL_Reg lib[] = {
        {"PollEvent", PollEvent},
        {"GetMillis", GetMillis},
        {"GetResolution", GetResolution},
        {"ToggleFullscreen", ToggleFullscreen},
        {"IsFocused", IsFocused},
        {"SetCursor", SetCursor},
        {"Sleep", Sleep},
        {NULL, NULL}
    };

    static int LuaOpen(lua_State *L) {
        luaL_newlib(L, lib);
        return 1;
    }
}