#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>

namespace Kitsune {
    class KitsuneApplet {
        public:
            SDL_Window* appletWindow = nullptr;
            SDL_Surface* appletSurface = nullptr;
            SDL_Surface* appletFont = nullptr;
            KitsuneApplet() {
                SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS);
                SDL_EnableScreenSaver();
                SDL_EventState(SDL_DROPFILE, SDL_ENABLE);
                atexit(SDL_Quit);
                SDL_DisplayMode dm;
                SDL_GetCurrentDisplayMode(0, &dm);
                this->appletWindow = SDL_CreateWindow("Kitsune", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, dm.w * 0.8, dm.h * 0.8, SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_HIDDEN);
                this->appletSurface = SDL_GetWindowSurface(this->appletWindow);
                this->appletFont = IMG_Load("data/ZapLightFont.png");
            }
            void show() {
                SDL_ShowWindow(this->appletWindow);
            }
            void renderGlyph() {

            }
    };
};