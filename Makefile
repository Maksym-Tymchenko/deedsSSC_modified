SOURCE1=src/deedsBCV0.cpp
SOURCE2=src/linearBCV.cpp
SOURCE3=src/applyBCV.cpp
SOURCE4=src/applyBCVfloat.cpp
SOURCE5=src/preprocessAbdomen.cpp

ifeq ($(SLOW),1)
	OPT =-O
else
	OPT =-O3 -fopenmp -mavx2 -msse4.2
endif

.PHONY: target

all: linear deeds apply applyFloat abdomen

deeds: $(SOURCE1) Makefile
	g++ $(SOURCE1) -I src -lz -o deedsBCV -std=c++11 $(OPT)

linear: $(SOURCE2) Makefile
	g++ $(SOURCE2) -I src -lz -o linearBCV -std=c++11 $(OPT)

apply: $(SOURCE3) Makefile
	g++ $(SOURCE3) -I src -lz -o applyBCV -std=c++11 $(OPT)

applyFloat: $(SOURCE4) Makefile
	g++ $(SOURCE4) -I src -lz -o applyBCVfloat -std=c++11 $(OPT)

abdomen: $(SOURCE5) Makefile
	g++ $(SOURCE5) -I src -lz -o preprocessAbdomen -std=c++11 $(OPT)

clean:
	rm -f deedsBCV, linearBCV

