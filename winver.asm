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

        mov     cx, 2                   ; up to 2 skipped zeros
        call    printnum                ; print major version

        mov     byte ptr [bx], '.'      ; append dot
        inc     bx

        pop     ax                      ; restore full version
        mov     al, ah                  ; move minor version to AL

        mov     cx, 1                   ; up to 1 skipped zero
        call    printnum                ; print minor version

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
;       CX - how many digits to skip at most when zero
;
; Uses:
;       AX, DL, CX
;
; Outputs:
;       BX - end of string offset
;
printnum proc near
        xor     ah, ah                  ; clear high byte
        push    ax                      ; save original number

        ;
        ; Hundreds
        ;

        mov     dl, 100
        div     dl                      ; AL = AX / 100 (hundreds digit)

        test    cx, cx                  ; if CX = 0
        jz      do_hundreds             ; don't skip trailing zero

        test    al, al                  ; if digit is zero
        jz      tens                    ; skip trailing zero

do_hundreds:
        call    printdigit              ; append to string

        ;
        ; Tens
        ;

tens:
        pop     ax                      ; restore original number

        mov     dl, 10
        div     dl                      ; AL = AX / 10 (tens digit)
                                        ; AL = AX % 10 (ones digit)

        dec     cx                      ; decrement trailing zero counter
        jz      do_tens                 ; don't skip if CX=0

        test    al, al                  ; if AL = 0
        jz      ones                    ; skip trailing zero

do_tens:
        call    printdigit              ; append to string

        ;
        ; Ones
        ;

ones:
        mov     al, ah                  ; move last digit to AL
        call    printdigit              ; append to string

        ret

printnum endp

;
; Formats a decimal digit and appends it to a string
;
; Inputs:
;       AL - digit to format
;       BX - string offset
;
; Uses:
;       AL, BX
;
; Outputs:
;       BX - incremented string offset
;
printdigit proc near
        add     al, '0'                 ; convert to ASCII digit
        mov     [bx], al                ; append to string
        inc     bx                      ; increment pointer

        ret
printdigit endp

        end     entry
