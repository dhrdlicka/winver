.model small
.8086
.stack 1000h

        extrn INITTASK          : far
        extrn WAITEVENT         : far
        extrn INITAPP           : far
        extrn GETVERSION        : far
        extrn MESSAGEBOX        : far

.data
org 10h
        Caption db 0
        Text    db "The Microsoft Windows Version is "
textend:

.code
        assume  cs:_TEXT
        assume  ds:DGROUP

        public  entry

entry proc near
        ;
        ; 16-bit Windows application startup
        ;

        call    INITTASK

        test    ax, ax                  ; if failed
        jz      exit                    ; exit

        ;xor    ax, ax
        ;push   ax                      ; hEvent = 0
        ;call   WAITEVENT               ; clear events counter

        push    di                      ; hInstance
        call    INITAPP

        test    ax, ax                  ; if failed
        jz      exit                    ; exit

        ;
        ; Get Windows version
        ;

        call    GETVERSION              ; AL = major ver
                                        ; AH = minor ver

        ;
        ; Format the message text
        ;

        ;push   bx                      ; save BX
        mov     bx, offset textend

        push    ax                      ; save full version

        mov     cl, 1                   ; minimum length 1
        call    print_number            ; print major version

        mov     byte ptr [bx], '.'      ; append dot
        inc     bx

        pop     ax                      ; restore full version
        mov     al, ah                  ; move minor version to AL

        mov     cl, 2                   ; minimum length 2
        call    print_number            ; print minor version

        mov     byte ptr [bx], '.'      ; append dot
        inc     bx

        mov     byte ptr [bx], 0        ; append null terminator

        ;pop    bx                      ; restore BX

        ;
        ; Display the message box
        ;

        xor     ax, ax
        push    ax                      ; hWndParent = 0 (HWND_DESKTOP)

        push    ds                      ; lpText selector
        mov     ax, offset Text
        push    ax                      ; lpText offset

        push    ds                      ; lpCaption selector
        mov     ax, offset Caption
        push    ax                      ; lpCaption offset

        xor     ax, ax
        push    ax                      ; wType = 0 (MB_OK)

        call    MESSAGEBOX              ; show message box

        ;
        ; Exit the program
        ;

exit:
        mov     ah, 4Ch                 ; terminate with status code
        int     21h                     ; DOS system call
entry endp

;
; Formats a byte as a decimal number and appends it to a string
;
; Inputs:
;       AL - byte to format
;       BX - string offset
;       CX - minimum length
;
; Uses:
;       AX, DX, CX
;
; Outputs:
;       BX - end of string offset
;
print_number proc near
        push    bp
        mov     bp, sp
        sub     sp, 2                   ; reserve 2 bytes of stack space

        mov     [bp - 2], cl            ; save minimum length to the stack

        mov     cx, 3                   ; loop three times
        mov     dx, 100                 ; maximum divisor

        xor     ah, ah                  ; clear high byte of AX

next_digit:
        div     dl                      ; divide current remainder by current divisor

        mov     ch, [bp - 2]
        cmp     cl, ch                  ; if we reached minimum length
        jle     print_digit             ; print the digit

        test    al, al                  ; if digit is zero
        jz      skip_digit              ; skip the digit

print_digit:
        add     al, '0'                 ; convert to ASCII digit
        mov     [bx], al                ; append to string
        inc     bx                      ; increment string pointer

skip_digit:
        push    ax                      ; save result

        mov     ax, dx
        mov     dl, 10
        div     dl                      ; divide divisor by 10
        mov     dl, al

        pop     ax                      ; restore result
        mov     al, ah                  ; move remainder to AL
        xor     ah, ah                  ; clear AH

        xor     ch, ch                  ; clear CH

        loop    next_digit

        mov     sp, bp
        pop     bp                      ; release stack frame

        ret

printnum endp

        end     entry
