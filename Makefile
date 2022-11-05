build:
	g++ src/Kitsune.cpp -o Kitsune -lSDL2 -lSDL2_image -llua5.4 -O2
clean:
	rm Kitsune