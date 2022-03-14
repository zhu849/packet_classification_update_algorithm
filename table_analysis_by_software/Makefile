CPP=g++
CFLAGS = -g -w -std=c++11 -fpermissive -O3 $(INCLUDE)

# LIBS = -lghthash
main:main.cpp ./KSet/KSet.cpp
	${CPP} ${CFLAGS} -o main main.cpp ./KSet/KSet.cpp

all:main
clean:
	rm main
