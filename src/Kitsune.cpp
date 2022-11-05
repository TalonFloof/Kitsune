char executablePath[2048];

#include <iostream>
#include "KitsuneApplet.cpp"
#include "KitsuneLuaCore.cpp"
#include "api/LuaAPIs.cpp"

#ifdef _WIN32
#include <windows.h>
#elif __linux__
#include <unistd.h>
#elif __APPLE__
#include <mach-o/dyld.h>
#endif

int main() {
    #if _WIN32
        int size = GetModuleFileName(NULL, executablePath, 2047);
        executablePath[size] = '\0';
    #elif __linux__
        int size = readlink("/proc/self/exe", executablePath, 2047);
        executablePath[size] = '\0';
    #elif __APPLE__
        int size = 2048;
        _NSGetExecutablePath(executablePath, &size);
    #else
        strcpy(executablePath, "./Kitsune")
    #endif

    Kitsune::KitsuneLuaCore luaCore;
    Kitsune::Applet::Initialize();
    Kitsune::Applet::Show();
    luaCore.runKitsuneCore();
    return 0;
}
