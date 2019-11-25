.686
.model flat, stdcall
option casemap : none

include \masm32\include\windows.inc
 include \masm32\include\user32.inc
 include \masm32\include\kernel32.inc
 include \masm32\include\fpu.inc ;
 includelib \masm32\lib\user32.lib
 includelib \masm32\lib\kernel32.lib
 includelib \masm32\lib\fpu.lib
 
.data
    MEM1 DQ -308670568.92005
    MEM2 DD 0
    ten DD 10
    zero DD 0
    temp DW 0
    siz DB 5
    header DB "Заголовок",0
    output DB 50 dup(?)
    template DB "First: %.2d",0
.code
start:
    mov esi, offset output
    fld MEM1
    fldz
    fcomip st(0), st(1)
    jl positive
    mov al, '-'
    mov [esi], al
    inc esi
positive:
    xor cx, cx ; Обнуляем счётчик
    fld MEM1 ;Загрузка числа
    fabs
    fld1    ;Загрузка единицы
    fld st(1) ;Копирование значения из st(0) в st(1)
    fprem  ; Деление st(0) на st(1)
    fabs
    fsubp st(2), st(0) ; Вычитание из st(2) st(0) - получаем в st(2) целую часть
    ffree st
    fincstp
loop1:
    fild ten
    fld st(1)
    fprem
    fabs
    fistp temp
    add temp, 30h
    push temp
    inc cx
    ;fxch st(1)
    fdivp st(1), st(0)
    fld1    ;Загрузка единицы
    fld st(1) ;Копирование значения из st(0) в st(1)
    fprem  ; Деление st(0) на st(1)
    fabs
    fsubp st(2), st(0) ; Вычитание из st(2) st(0) - получаем в st(2) целую часть
    ffree st(0)
    fincstp
    fldz
    fcomip st(0), st(1)
    jnz loop1
    ffree st(0)
loop2:
    pop ax
    mov [esi], al
    inc esi
    loop loop2
    mov al, '.'
    mov [esi], al
    inc esi
    fld MEM1
    fabs
    fld1
    fxch st(1)
    fprem
    fabs
    ffree st(1)
    mov cl, siz
loop_tens:
    fild ten
    fmulp st(1), st(0)
    loop loop_tens
    fld1    ;Загрузка единицы
    fld st(1) ;Копирование значения из st(0) в st(1)
    fprem  ; Деление st(0) на st(1)
    fabs
    fsubp st(2), st(0) ; Вычитание из st(2) st(0) - получаем в st(2) целую часть
    ffree st
    fincstp
loop3:
    fild ten
    fld st(1)
    fprem
    fabs
    fistp temp
    add temp, 30h
    push temp
    inc cx
    dec siz
    fdivp st(1), st(0)
    fld1    ;Загрузка единицы
    fld st(1) ;Копирование значения из st(0) в st(1)
    fprem  ; Деление st(0) на st(1)
    fabs
    fsubp st(2), st(0) ; Вычитание из st(2) st(0) - получаем в st(2) целую часть
    ffree st(0)
    fincstp
    fldz
    fcomip st(0), st(1)
    jnz loop3
    ffree st(0)
loop4:
    pop ax
    mov [esi], al
    inc esi
    loop loop4

    invoke MessageBox, NULL, addr output, addr header, MB_OK
    invoke ExitProcess,0
end start ;
    