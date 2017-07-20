all: VirtualOS.bin

VirtualOS.bin: VirtualOS.asm
	nasm -o VirtualOS.bin VirtualOS.asm

clean:
	rm -f VirtualOS.bin

#부트로더 asm파일을 nasm 어셈블리어 컴파일러로 빌드하여 BootLoader.bin 파일을 생성하는 것입니다. 부트로더 파일을 clean Target이 정의 되어 있으며 자신은 디렉터리에 있는 부트로더 바이너리 파일을 삭제합니다.