all: Kernel32.bin

Kernel32.bin: Source/EntryPoint.s
	nasm -o Kernel32.bin $<
clean:
	rm -f Kernel32.bin
	
	
	
#<$은 매크로로 써 Dependency (:의 왼쪽) 의 처선째 파일을 의미하는 매크로이다 따라서 이는 Source/EntryPoint.s로 치환되며 이 엔트리 파일을 빈들되어 kernel32.bin파일로 생성됩니다.
#부트로더 asm파일을 nasm 어셈블리어 컴파일러로 빌드하여 BootLoader.bin 파일을 생성하는 것입니다. 부트로더 파일을 clean Target이 정의 되어 있으며 자신은 디렉터리에 있는 부트로더 바이너리 파일을 삭제합니다.