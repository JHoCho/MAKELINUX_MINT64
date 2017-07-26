[ORG 0x00]			;코드의 시작으로 어드레스를 설정
[BITS 16]			; 이하의 코드는 16비트로 설정

SECTION .text		;text섹션을 정의
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	코드영역
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
START:
	mov ax,0x1000		;보호모드 엔트리 포인트의 시작 어드레스를 세그먼트 레지스터 값으로 변환
	mov ds, ax 			;DS세그먼트 레지스터에 설정
	mov es, ax			;ES세그먼트 레지스터에 설정.

	cli					;인터럽트가 발생하지 못하도록 설정
	lgdt[GDTR]			;GDTR자료구조를 프로세서에 설정하여 gdt테이블을 로드
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;	보호 모드로 진입
	;	Disable Paging,Disable Cache Internal FPU, Disable Align Check,
	;	Enable ProtectedMode
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov eax, 0x4000003B	;PG =0 CD =1 NW=0 , AM=0, WP=0,NE=1, ET=1,TS=1,EM=0,MP=1,PE=1
	mov cr0, eax		;

	jmp dword 0x08: (PROTECTEDMODE -$$ +0x10000)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	보호모드로 진입
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[BITS 32]		;이하의 코드는 32비트로 설정
PROTECTEDMODE:
	mov ax, 0x10		;보호모드 커널용 뎅터 세그먼트 디스크립터를 AX레지스터에 저장
	mov ds, ax			;DS세그먼트 셀렉터에 설정
	mov es, ax			;ES 세그먼트 셀렉터에 설정
	mov fs, ax			;FS 세그먼트 셀렉터에 설정
	mov gs, ax			;GS 세그먼트 셀렉터에 설정

		;스택을 0x00000000~0x0000FFFF	영역에 64KB 크기로 생성
	mov ss,ax			;SS세그먼트 셀렉터에 설정
	mov esp,0xFFFE		;ESP레지스터의 어드레스를 0xFFFE로 설정
	mov ebp,0xFFFE		;EBP레지스터의 어드레스를 0xFFFE로 설정

		;화면에 보호 ㅗ드로 전환되었다는 메세지를 찍는다.
	push (	SWITCHSUCCESSMESSAGE -$$ + 0x10000 ) 	;출력할 메시지의 어드레스를 스택에 삽입
	push 2											;화면 Y 좌표2를 스택에 삽입
	push 0											;화면 X 좌표를 스택에 삽입
	call PRINTMESSAGE								;PRINTMESSAGE함수 호출
	add esp, 12										;삽입한 파라미터 제거

	jmp $				;현재 위치에서 무한루프 수행.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	함수 코드 영역
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;메세지를 출력하는 함수
; 스택에 x,y,문자열
PRINTMESSAGE:
	push ebp					;base pointer register 을 스택에 삽입
	mov ebp, esp				; bp에 스텍 포인터 레지스터의 값을 설정
	push esi					; 함수에서 임시로 사용하는 레지스터로 함수의 마지막 부분에서
	push edi					;	스택에 삽입된 값을 꺼내 원래 값으로 복원
	push eax
	push ecx
	push edx

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;	 X,Y의 좌표로 비디오 메모리의 어드레스를 계산함.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Y좌표를 이용해서 먼저 라인 어드레스를 구함.
	mov eax, dword [ ebp +12 ]	;파라미터 2 를 설정.
	mov esi, 160		; 한 라인의 바이트 수 2*80 를 ESI(스텍쪽)레지스터에 설정
	mul esi				; eax레지스터와 ESI 레지스터를 곱하여 화면 X 어드레스를 계산
	mov edi, eax		; 화면 어드레스를 EDI(지시자) 에 저장

	mov eax, dword [ebp + 8]	;파라ㅣ터 1 을 EAX레지스터에 설정.
	mov esi, 2			;한 문자를 나타내는 바이트수를 ESI레지스터에 설정
	mul esi				;EAX레지스터와 ESI레지스터를 곱하여 화면 X어드레스를 계산
	add edi, eax		;화면 Y어드레스와 계산된 X 어드레스를 더해서 실제 비디오 메모리 어드레스를 계산
	;출력할 문자열의 어드레스
	mov esi, dword[ ebp + 16]			;파라미터 3( 출력할 문자열의 어드레스)

.MESSAGELOOP:						;메세지를 출력하는 루프
	mov cl, byte [ esi]				;ESI레지스터가 가리키는 문자열 취이에서 한 문자ㄹ를 CL레지스터에 복사, CL레지스터는 ECX레지스터의 하위 1바이트를 의미

	cmp cl, 0						;복사된 문자와 0을 비교
	je .MESSAGEEND					;복사된 문자의 값이 0이면 문자열이 종료되었음을 의미함으로 .MESSAGE END로 가서 종료 같으면 점프

	mov byte[edi + 0xB8000],cl		;0이 아니라면 비디오 메모리 어드레스 0x8000 + EDI에 문자열을 출력

	add esi, 1						;ESI레지스터에 1을 더하여 다음 문자열로 이동
	add edi, 2						; EDI레지스터에 2를 더하여 비디오 메모리의 다음 문자위치로 이동, 비디오 메모리는 문자 속성의 쌍으로 구성되므로 문자만 출력하려면 2를 더해야합니다.

	jmp .MESSAGELOOP				;	메세지 출력 루프로 이동하여 다음 문자를 출력
.MESSAGEEND:
	pop	edx							;	함수에서 사용이 끝난 EDX레지스터로부터 EBP레지스터까지를 스텍에 삽입된 값을 이용해 복원하며
	pop ecx							;	스택을 가장 마지막에 드어간 데이터가 가장 먼저 나오는 자료구조이므로
	pop eax							;	삽입의 역순으로 제거해야한다.
	pop edi
	pop esi
	pop ebp							;베이스 포인터 레지스터 복원
	ret								; 함수를 호출한 다음 코드의 위치로 복귀

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;		데이터 영역
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; 아래의 데이터들을 8 바이트에 맞춰 정렬하기 위해 추가
align 8, db 0
	;GDTR의 끝을 8 바이트로 정렬하기 위해 추가
dw 0x0000
	;GDTR 자료구조 정의
GDTR:
		dw GDTEND - GDT - 1				;아래에 위치하는 GDT테이블의 전체크기
		dd ( GDT -$$ + 0x10000)			;아래에 위치하는 GDT테이블의 시작 어드레스
	;GDT테이블 정의
GDT:
		;null 디스크럽터 반드시 0으로 초기화 해야한다.
	NULLDescriptor:
		dw 0x0000
		dw 0x0000
		db 0x00
		db 0x00
		db 0x00
		db 0x00

	CODEDESCRIPTOR:
		dw 0xFFFF		;limit 15:0
		dw 0x0000		;base 15:0
		db 0x00			;base 23 16
		db 0x9A			;P=1 DPL=0 Code Segment Execute Read
		db 0xCF			;G=1 D=1 L=0 limit[19:16]
		db 0x00			;Base [31:24]
		;보호 모드 커널용 데이터 세그먼트 디스크럽터.
	DATADESCRIPTOR:
		dw 0xFFFF		; Limit 15:0
		dw 0x0000		; Base 15:0
		db 0x00			; Base 23:16
		db 0x92			; P=1 DPL =0  Data Segment Read/Write
		db 0xCF			; G=1 D=1 L=0	Limit 19:16
		db 0x00			;  Base 31 24
GDTEND:
		;보호 모드로 전환 되었다는 메세지
SWITCHSUCCESSMESSAGE: db 'Switch To Protected Mode Success ~!!',0
times 512 - ($ - $$) db 0x00	;512 바이트를 맞추기 위해 남은 부분을 0으로 채움.













