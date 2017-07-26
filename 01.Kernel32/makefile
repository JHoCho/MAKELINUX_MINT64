##################################################
# 빌드 환경 및 규칙 설정
##################################################
NASM32 = nasm
GCC32 = x86_64-pc-linux-gcc.exe -c -m32 -ffreestanding
LD32 = x86-64-pc-linux-ld.exe -melf_i386 -T ../elf_i386.x -nostdlib -e Main -Ttext 0x10200
OBJCOPY32 = x86_64-pc-linux-objcopy -j .text -j .data -j .rodata -j .bss -S -O binary

OBJECTDIRECTORY = Temp
SOURCEDIRECTORY = Source

##################################################
# 빌드 항목 및 빌드 방법 설정
##################################################
all : prepare Kernel32.bin

prepare:
	mkdir -p $(OBJECTDIRECTORY)
	
$(OBJECTDIRECTORY)/EntryPoint.bin : $(SOURCEDIRECTORY)/EntryPoint.s
	$(NASM32) -o $@ $<

dep:
	@echo === Make Dependancy File ===
	make 0C $(OBJECTDIRECTORY)	-f ../makefile InternalDependency
	@echo === Dependancy Search Complete ===
ExecuteInternalBuild: dep
	make -C $(OBJECTDIRECTORY) -f ../makefile Kernel32.elf
	
$(OBJECTDIRECTORY)/Kernel32.elf.bin: ExecuteInternalBuild
	$(OBJCOPY32) $(OBJECTDIRECTORY)/Kernel32.elf $@

Kernel32.bin: $(OBJECTDIRECTORY)/EntryPoint.bin $(OBJECTDIRECTORY)/Kernel32.elf.bin
	cat $^ > $@
	
clean:
	rm -f *.bin
	rm -f $(OBJECTDIRECTORY)/*.*
##################################################
# Make 에 의해 다시 호출되는 부분 TENO디렉터리를 기준으로 수행됨
##################################################
CENTRYPOINTOBJECTFILE = Main.o
CSOURCEFILES = $(wildcard ../$(SOURCEDIRECTORY)/*.c)
ASSEMBLYSOURCEFILES = $(wildcard ../$(SOURCEDIRECTORY)/*.asm)
COBJECTFILES = $(subst Main.o, , $(notdir $(patsubst %.c,%.o,$(CSOURCEFILE))))
ASSEMBLYOBJECTFILES = $(notdir $(patsubst %.asm,%.o,$(ASSEMBLYSOURCEFILES)))

# .c 파일을 .o 파일로 바꾸는 규칙 정의  
%.o: ../$(SOURCEDIRECTORY)/%.c
		$(GCC32) -c $<

# .asm파일을 .o파일로 바꾸는 규칙 정의
%.o: ../$(SOURCEDIRECTORY)/%.asm
		$(NASM32) -f elf32 -o $@ $<
		
InternalDependency:
	$(GCC32) -MM $(CSOURCEFILES)>Dependency.dep

Kernel32.elf: $(CENTRYPOINTOBJECTFILE) $(COBJECTFILES) $(ASSEMBLYOBJECTFILES)
	$(LD32) -o $@ $^
	
ifeq (Dependency.dep, $(wildcard Dependency.dep))
include Dependency.dep
endif

#<$은 매크로로 써 Dependency (:의 왼쪽) 의 처선째 파일을 의미하는 매크로이다 따라서 이는 Source/EntryPoint.s로 치환되며 이 엔트리 파일을 빈들되어 kernel32.bin파일로 생성됩니다.
#부트로더 asm파일을 nasm 어셈블리어 컴파일러로 빌드하여 BootLoader.bin 파일을 생성하는 것입니다. 부트로더 파일을 clean Target이 정의 되어 있으며 자신은 디렉터리에 있는 부트로더 바이너리 파일을 삭제합니다.