#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>

namespace Kitsune::Applet {
    static SDL_Window* appletWindow = nullptr;
    static SDL_Surface* appletSurface = nullptr;
    static SDL_Renderer* appletRenderer = nullptr;
    static SDL_Texture* appletFont = nullptr;
    void Initialize() {
        SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS);
        SDL_EnableScreenSaver();
        SDL_SetHint(SDL_HINT_FRAMEBUFFER_ACCELERATION, "1");
        SDL_EventState(SDL_DROPFILE, SDL_ENABLE);
        atexit(SDL_Quit);
        SDL_DisplayMode dm;
        SDL_GetCurrentDisplayMode(0, &dm);
        appletWindow = SDL_CreateWindow("Kitsune", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_HIDDEN);
        appletRenderer = SDL_CreateRenderer(appletWindow, -1, SDL_RENDERER_ACCELERATED);
        appletSurface = SDL_GetWindowSurface(appletWindow);
        appletFont = IMG_LoadTexture(appletRenderer, "data/ZapLightFont.png");
    }
    void Show() {
        SDL_ShowWindow(appletWindow);
    }
};