all: ImageMaker.exe

ImageMaker.exe: 00.ImageMaker/ImageMaker.c
		gcc -o $@ $<
		cp $@ ../
clean:
		rm -f ImageMaker.exe