format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'size of vector? ', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strFirstNeg    db 'first negatuve value %d', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size     dd 0
        sum          dd 0
        help         dd ?
        negv         dd 0
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        vec          rd 1024
        vec2         rd 1024

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput
; 3) test vector out
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size]
        cmp eax, 0
        jle  failedSize
        cmp eax, 1024
        jg failedSize
; else continue...
getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec
	mov edx, vec2


getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [ebx]
        cmp eax, 0
        call newNeg
	cmp eax, 0
	call comparer

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
	add edx, 4
        jmp getVecLoop
endInputVector:
        push [min]
        push strMinVal
        call [printf]
        add esp, 8
        ret

;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vec2           ; ebx = &vec
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret
;--------------------------------------------------------------------------
failedSize:
        push vec_size
        push strIncorSize
        call [printf]
        push 0
        call [ExitProcess]
newNeg:                      ;Сравнение с 0, если отрицательно 1
        jl newNeg1
        ret
newNeg1:                     ;Отметка, что прошло отрицательное
	mov [negv], 1
	ret
comparer:
        je isnull
        mov [edx], eax
        ret
isnull:
	cmp [negv], 1
	call pushone
	ret
pushone:
        mov edx, 1
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'
