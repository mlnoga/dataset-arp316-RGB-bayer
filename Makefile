# General settings
OBJ =Arp316

# Example for LRGB
CHAN=RGB
RGB=
COMBINE=-chroma 2.0 -scnr 1.0 -autoScale 0.0125 -ppGamma 2.0 -ppSigma 2.0 -scaleBlack 5.5
#COMBINE=-chroma 1.9 -autoScale 0.1 -ppGamma 3.0 -ppSigma 2.0 -scaleBlack 7.84
#COMBINE=-chroma 2.5 -scnr 1.0 -autoScale 0.0125 -ppGamma 3.0 -ppSigma 2.0 -scaleBlack 5.5
#COMBINE=-chroma 2.5 -scnr 1.0 -autoScale 0.0125 # 2 
#COMBINE=-chroma 2.5 -scnr 1.0 -autoScale 0.0125 -ppGamma 3.5 -ppSigma 2.75 -scaleBlack 7.84   # 1

# Provide paths to your master dark frames here (they depend on exposure length, temperature, gain and bias)
DARKL =""
DARKR =""
DARKG =""
DARKB =""
DARKHa=""
DARKO3=""
DARKS2=""

# Provide paths to your master flat frames here (they mostly depend on the filter, as well as on gain and bias)
FLATL =""
FLATR =""
FLATG =""
FLATB =""
FLATHa=""
FLATO3=""
FLATS2=""

# Additional per-channel settings (put e.g. pre-determined stacking sigmas here to avoid the goal seek)
PARAML =
PARAMR =-bpSigLow 0 -bpSigHigh 0 -stWeight 1 
PARAMG =-bpSigLow 0 -bpSigHigh 0 -stWeight 1 
PARAMB =-bpSigLow 0 -bpSigHigh 0 -stWeight 1 
PARAMHa=
PARAMO3=
PARAMS2=

# Additional overall settings (typically not necessary)
STD    =#-stMemory 2500

# Set the path to your nightlight executable here
NL     =nightlight


# Makefile targets and rules. These should usually not require any changes

LS=$(wildcard L/*.fits) $(wildcard L/*.fit)
RS=$(patsubst %,session%/$(OBJ)_R.fits,1 2 3 4)
GS=$(patsubst %,session%/$(OBJ)_G.fits,1 2 3 4)
BS=$(patsubst %,session%/$(OBJ)_B.fits,1 2 3 4)
HaS=$(wildcard Ha/*.fits) $(wildcard Ha/*.fit)
O3S=$(wildcard O3/*.fits) $(wildcard O3/*.fit)
S2S=$(wildcard S2/*.fits) $(wildcard S2/*.fit)

all: $(OBJ)_$(CHAN).fits

backup:
	mkdir -p backup && mv *.fits *.jpg *.log backup/

clean: 
	rm -f $(OBJ)_RGB.fits $(OBJ)_LRGB.fits $(OBJ)_HaS2O3.fits $(OBJ)_HaO3S2.fits $(OBJ)_S2HaO3.fits $(OBJ)_HaO3O3.fits $(OBJ)_HaS2S2.fits \
	$(OBJ)_RGB.jpg $(OBJ)_LRGB.jpg $(OBJ)_HaS2O3.jpg $(OBJ)_HaO3S2.jpg $(OBJ)_S2HaO3.jpg $(OBJ)_HaO3O3.jpg $(OBJ)_HaS2S2.jpg \
	$(OBJ)_RGB.log $(OBJ)_LRGB.log $(OBJ)_HaS2O3.log $(OBJ)_HaO3S2.log $(OBJ)_S2HaO3.log $(OBJ)_HaO3O3.log $(OBJ)_HaS2S2.log 

realclean: clean
	rm -f $(OBJ)_L.fits $(OBJ)_R.fits $(OBJ)_G.fits $(OBJ)_B.fits \
	$(OBJ)_Ha.fits $(OBJ)_O3.fits $(OBJ)_S2.fits \
	$(OBJ)_L.log $(OBJ)_R.log $(OBJ)_G.log $(OBJ)_B.log \
	$(OBJ)_Ha.log $(OBJ)_O3.log $(OBJ)_S2.log 

spotless: realclean
	for s in session? ; do make -C $$s realclean ; done

folders:
	for f in *_L_*.fits; do if test -f "$$f";  then mkdir -p L;  mv *_L_*.fits  L/;  fi; break; done
	for f in *_R_*.fits; do if test -f "$$f";  then mkdir -p R;  mv *_R_*.fits  R/;  fi; break; done
	for f in *_G_*.fits; do if test -f "$$f";  then mkdir -p G;  mv *_G_*.fits  G/;  fi; break; done
	for f in *_B_*.fits; do if test -f "$$f";  then mkdir -p B;  mv *_B_*.fits  B/;  fi; break; done
	for f in *_Ha_*.fits; do if test -f "$$f"; then mkdir -p Ha; mv *_Ha_*.fits Ha/; fi; break; done
	for f in *_O3_*.fits; do if test -f "$$f"; then mkdir -p O3; mv *_O3_*.fits O3/; fi; break; done
	for f in *_S2_*.fits; do if test -f "$$f"; then mkdir -p S2; mv *_S2_*.fits S2/; fi; break; done

count:
	for f in L R G B Ha O3 S2; do if test -e "$$f"; then echo "$$f" has `ls $$f | wc -l` frames; fi ; done

%.stats: %.fits 
	$(NL) $(STD) $(STATS) -log $@ stats $^

%_S2HaO3.fits: %_S2.fits %_Ha.fits %_O3.fits
	$(NL) $(STD) $(COMBINE) -out $@ rgb $^

%_HaS2O3.fits: %_Ha.fits %_S2.fits %_O3.fits
	$(NL) $(STD) $(COMBINE) -out $@ rgb $^

%_HaO3S2.fits: %_Ha.fits %_O3.fits %_S2.fits 
	$(NL) $(STD) $(COMBINE) -out $@ rgb $^

%_HaO3O3.fits: %_Ha.fits %_O3.fits
	$(NL) $(STD) $(COMBINE) -out $@ rgb $^ $*_O3.fits

%_HaS2S2.fits: %_Ha.fits %_S2.fits
	$(NL) $(STD) $(COMBINE) -out $@ rgb $^ $*_S2.fits

%_RGB.fits: %_R.fits %_G.fits %_B.fits
	$(NL) $(STD) $(COMBINE) -out $@ rgb $^

%_aRGB.fits: %_L.fits %_R.fits %_G.fits %_B.fits
	$(NL) $(STD) $(COMBINE) -out $@ argb $^

%_LRGB.fits: %_L.fits %_R.fits %_G.fits %_B.fits
	$(NL) $(STD) $(COMBINE) -out $@ lrgb $^

%_HaRGB.fits: %_Ha.fits %_R.fits %_G.fits %_B.fits
	$(NL) $(STD) $(COMBINE) -out $@ lrgb $^

$(OBJ)_L.fits: $(LS)
	$(NL) $(STD) $(PARAML) -dark $(DARKL) -flat $(FLATL) -out $@ stack $(LS)

$(OBJ)_R.fits: $(RS)
	$(NL) $(STD) $(PARAMR) $(RGB) -dark $(DARKR) -flat $(FLATR) -out $@ stack $(RS)

$(OBJ)_G.fits: $(GS)
	$(NL) $(STD) $(PARAMG) $(RGB) -dark $(DARKG) -flat $(FLATG) -out $@ stack $(GS)

$(OBJ)_B.fits: $(BS)
	$(NL) $(STD) $(PARAMB) $(RGB) -dark $(DARKB) -flat $(FLATB) -out $@ stack $(BS)

$(OBJ)_Ha.fits: $(HaS)
	$(NL) $(STD) $(PARAMHa) -dark $(DARKHa) -flat $(FLATHa) -out $@ stack $(HaS)

$(OBJ)_O3.fits: $(O3S)
	$(NL) $(STD) $(PARAMO3) -dark $(DARKO3) -flat $(FLATO3) -out $@ stack $(O3S)

$(OBJ)_S2.fits: $(S2S)
	$(NL) $(STD) $(PARAMS2) -dark $(DARKS2) -flat $(FLATS2) -out $@ stack $(S2S)

session%/$(OBJ)_R.fits:
	make -C session$*/ $(OBJ)_R.fits

session%/$(OBJ)_G.fits:
	make -C session$*/ $(OBJ)_G.fits

session%/$(OBJ)_B.fits:
	make -C session$*/ $(OBJ)_B.fits