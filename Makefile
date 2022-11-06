build_linux:
	g++ src/Kitsune.cpp -o Kitsune -lSDL2 -lSDL2_image -llua5.4 -O2

build_windows:
	g++ src/Kitsune.cpp -o Kitsune.exe -lmingw32 -lSDL2main -lSDL2 -lSDL2_image -llua5.4 -O2 -mwindows
	
clean:
	rm Kitsune