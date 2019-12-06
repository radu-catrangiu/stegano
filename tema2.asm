%include "include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
	use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1

section .text
global main


print_matrix:
    push ebp
    mov ebp, esp

    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    sub esp, 4

    mov esi, [img]
    mov ecx, [img_width]
    mov eax, [img_height]
    mul ecx                         ; MUL realizeaza EAX <- EAX * ECX
    xor ecx, ecx
    mov [ebp - 4], eax

    PRINT_UDEC 4, 0 ;AICI AVEM INDEXUL LINIEI
    PRINT_STRING "   "
    print_matrix_loop:

        PRINT_CHAR [esi + 4 * ecx] ; Mod de accesare
        ; PRINT_STRING " "

        mov eax, ecx
        inc eax

        xor edx, edx
        div DWORD [img_width]

        ;; DEBUGGING CODE START
        test edx, edx
        jnz skip_newline
        NEWLINE
        PRINT_UDEC 4, eax ;AICI AVEM INDEXUL LINIEI
        PRINT_STRING "   "
        skip_newline:
        ;; DEBUGGING CODE END

    inc ecx
    cmp ecx, [ebp - 4]
    jne print_matrix_loop

    NEWLINE

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    mov esp, ebp
    pop ebp
    ret
; end print_matrix


; Function that XORs two values
; two params => 
;   valueA = DWORD size
;   valueB = DWORD size
xor_values:
    push ebp
    mov ebp, esp

    xor esi, esi
    xor edi, edi

    mov esi, [ebp + 12]
    mov edi, [ebp + 8]

    mov eax, [esi]
    xor eax, edi

    ; PRINT_UDEC 1, [esi] ; Mod de accesare ; FOR DEBUGGING
    ; PRINT_STRING " XOR "                  ; FOR DEBUGGING
    ; PRINT_UDEC 1, edi                     ; FOR DEBUGGING
    ; PRINT_STRING " = "                    ; FOR DEBUGGING
    ; PRINT_UDEC 1, eax                     ; FOR DEBUGGING
    ; NEWLINE                               ; FOR DEBUGGING

    mov esp, ebp
    pop ebp
    ret
; end xor_values


; Function that XORs the matrix
; one param => KEY = BYTE size
xor_matrix:
    push ebp        ; save the value of ebp
    mov ebp, esp    ; ebp now points to the top of the stack

    mov ecx, [img_width]
    mov eax, [img_height]
    mul ecx                         ; MUL realizeaza EAX <- EAX * ECX
    mov ecx, eax

    ; PRINT_UDEC 1, [ebp + 8] ; FOR DEBUGGING
    ; NEWLINE                 ; FOR DEBUGGING

    xor_matrix_loop:
        ;; store in edi the address of the value
        mov esi, [img]
        lea edi, [esi + 4 * (ecx - 1)] ; edi = &(a[i])

        ;; store key in eax
        xor eax, eax
        mov BYTE al, [ebp + 8]

        ;; xor value and key => result in eax
        push edi
        push eax
        call xor_values

        ;; overwrite value with eax
        mov esi, [img]
        mov [esi + 4 * (ecx - 1)], eax

    dec ecx
    test ecx, ecx
    jnz xor_matrix_loop

    mov esp, ebp
    pop ebp
    ret
; end xor_matrix

get_line_number:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]

    inc eax
    xor edx, edx
    div DWORD [img_width]

    ; ;; DEBUGGING CODE START
    ; test edx, edx
    ; jnz skip_newline
    ; NEWLINE
    ; PRINT_UDEC 4, eax ;AICI AVEM INDEXUL LINIEI
    ; PRINT_STRING " "
    ; skip_newline:
    ; ;; DEBUGGING CODE END

    mov esp, ebp
    pop ebp
    ret
; end get_line_number

check_revient:
    push ebp        ; save the value of ebp
    mov ebp, esp    ; ebp now points to the top of the stack

    xor ecx, ecx

    mov esi, [ebp + 12] ;; img
    mov edi, [ebp + 8]  ;; "revient"
    check_revient_loop:
        xor ebx, ebx
        xor edx, edx

        mov ebx, [esi + 4 * ecx] ;; img e stocat pe cate 4 octeti
        mov BYTE dl, [edi + ecx] ;; "revient" e pe cate un octet

        mov eax, 1
        cmp ebx, edx
        jnz check_revient_no_match;

        ; PRINT_CHAR ebx
        ; PRINT_STRING " "
        ; PRINT_CHAR edx
        ; NEWLINE

    inc ecx
    cmp ecx, 7
    jnz check_revient_loop

    check_revient_match:
    mov eax, 0

    check_revient_no_match:
    mov esp, ebp
    pop ebp
    ret
; end check_revient

find_revient:
    push ebp        ; save the value of ebp
    mov ebp, esp    ; ebp now points to the top of the stack

    sub esp, 8      ; local variable "revient" string
    mov BYTE [ebp - 8], 'r'
    mov BYTE [ebp - 7], 'e'
    mov BYTE [ebp - 6], 'v'
    mov BYTE [ebp - 5], 'i'
    mov BYTE [ebp - 4], 'e'
    mov BYTE [ebp - 3], 'n'
    mov BYTE [ebp - 2], 't'
    mov BYTE [ebp - 1], 0

    mov ecx, [img_width]
    mov eax, [img_height]
    mul ecx          ; MUL realizeaza EAX <- EAX * ECX
    mov ecx, eax
    mov edx, eax
    
    find_revient_loop:
        mov esi, [img]

        mov eax, edx
        sub eax, ecx

        push eax
        push ecx
        push edx
        push esi

        xor ebx, ebx
        lea ebx, [esi + 4 * eax]
        push ebx ;; 2nd argument = current string
        xor ebx, ebx
        lea ebx, [ebp - 8]
        push ebx ;; 1st argument = "revient" string
        call check_revient
        add esp, 8 ;; skip arguments

        mov ebx, eax

        pop esi
        pop edx
        pop ecx
        pop eax

        ; PRINT_HEX 4, ebx
        ; NEWLINE
        test ebx, ebx
        jz find_revient_found_match

    dec ecx
    test ecx, ecx
    jnz find_revient_loop

    mov eax, [img_height]

    mov esp, ebp
    pop ebp
    ret

    find_revient_found_match:
    push eax ;; Push argument
    call get_line_number
    add esp, 4 ;; SKIP argument
    ; PRINT_UDEC 4, eax ;; IN EAX ESTE NUMARUL LINIEI
    ; NEWLINE
    
    mov esp, ebp
    pop ebp
    ret
; end find_revient

; Task1 main function
bruteforce_singlebyte_xor:
    push ebp        ; save the value of ebp
    mov ebp, esp    ; ebp now points to the top of the stack

    sub esp, 1      ; local variable KEY
    mov BYTE [ebp - 1], 0x00      ; KEY = 0

    ; call print_matrix ; FOR DEBUGGING

    singlebyte_bruteforce_loop:
        ;; XOR MATRIX
        xor eax, eax
        mov BYTE al, [ebp - 1]
        push eax
        call xor_matrix

        ;; CHECK FOR WORD "revient"
        call find_revient
        cmp eax, [img_height]
        jnz singlebyte_bruteforce_key_found

        ;; REVERT CHANGES
        xor eax, eax
        mov BYTE al, [ebp - 1]
        push eax
        call xor_matrix

        ; call print_matrix ; FOR DEBUGGING

    inc BYTE [ebp - 1]
    test BYTE [ebp - 1], 0xFF
    jnz singlebyte_bruteforce_loop

    singlebyte_bruteforce_key_found:
    xor ebx, ebx
    mov bl, [ebp - 1]

    mov esp, ebp
    pop ebp
    ret
; end bruteforce_singlebyte_xor


compute_new_key:
    push ebp        ; save the value of ebp
    mov ebp, esp    ; ebp now points to the top of the stack

    ; NEWLINE
    ; PRINT_STRING "COMPUTE_NEW_KEY - OLD KEY: "
    ; PRINT_UDEC 4, [ebp + 8]
    ; NEWLINE

    mov eax, [ebp + 8]
    mov ebx, 2
    mul ebx
    add eax, 3
    mov ebx, 5
    div ebx
    sub eax, 4

    ; PRINT_STRING "COMPUTE_NEW_KEY - NEW KEY: "
    ; PRINT_UDEC 4, eax
    ; NEWLINE

    mov esp, ebp
    pop ebp
    ret
; end compute_new_key


write_msg_and_encode:
    push ebp        ; save the value of ebp
    mov ebp, esp    ; ebp now points to the top of the stack

    sub esp, 28 ; "C'est un proverbe francais."
    mov DWORD [ebp - 28], "C'es"
    mov DWORD [ebp - 24], "t un"
    mov DWORD [ebp - 20], " pro"
    mov DWORD [ebp - 16], "verb"
    mov DWORD [ebp - 12], "e fr"
    mov DWORD [ebp -  8], "anca"
    mov BYTE [ebp - 4], 'i'
    mov BYTE [ebp - 3], 's'
    mov BYTE [ebp - 2], '.'
    mov BYTE [ebp - 1], 0
    ; PRINT_STRING [ebp - 28] ; "C'est un proverbe francais."

    ; NEWLINE
    ; PRINT_STRING "New key: "
    ; PRINT_UDEC 4, [ebp + 8]
    ; NEWLINE
    ; PRINT_STRING "Line to write to: "
    ; PRINT_UDEC 4, [ebp + 12]
    ; NEWLINE

    mov esi, [img]

    mov eax, [ebp + 12]
    mov edi, [img_width]
    mul edi

    ; PRINT_STRING [esi + 4 * ecx]
    ; NEWLINE
    xor ecx, ecx

    lea edi, [ebp - 28]
    write_msg:
        ; mov ebx, [esi + 4 * ecx]
        xor edx, edx
        mov BYTE dl, [edi + ecx]
        mov [esi + 4 * eax], edx
        inc eax
        mov ebx, [esi + 4 * ecx]
        ; PRINT_CHAR edx
        ; PRINT_STRING " "
        ; PRINT_CHAR ebx  
        ; NEWLINE
        cmp ecx, 27 ; strlen() - 1
        jz end_write_msg
    inc ecx
    jmp write_msg
    end_write_msg:

    push DWORD [ebp + 8]
    call xor_matrix

    mov esp, ebp
    pop ebp
    ret
; end write_msg_and_encode

;; int write_morse(char x, int *img, int byte_id)
;; intoarce numarul de caractere scrise
write_morse:
    push ebp        ; save the value of ebp
    mov ebp, esp    ; ebp now points to the top of the stack

    mov bl, [ebp + 8]

    ; PRINT_CHAR [ebp + 8]
    ; PRINT_STRING " "
    ; PRINT_UDEC 4, [ebp + 16]
    ; PRINT_STRING " "
    mov edx, [ebp + 16] ;; byte_id
    mov edi, [ebp + 12] ;; *img
    ; PRINT_CHAR [edi + 4 * edx]
    ; NEWLINE

    ;; Write to image
    ; mov eax, [ebp + 8]
    ; mov [edi + 4 * edx], eax

    ; xor eax, eax
    ; mov eax, 1

    cmp bl, 0x00,
    je write_terminator
    cmp bl, ','
    je encrypt_COMMA
    cmp bl, ' '
    je encrypt_BLANK
    cmp bl, 'A'
    je encrypt_A
    cmp bl, 'B'
    je encrypt_B
    cmp bl, 'C'
    je encrypt_C
    cmp bl, 'D'
    je encrypt_D
    cmp bl, 'E'
    je encrypt_E
    cmp bl, 'F'
    je encrypt_F
    cmp bl, 'G'
    je encrypt_G
    cmp bl, 'H'
    je encrypt_H
    cmp bl, 'I'
    je encrypt_I
    cmp bl, 'J'
    je encrypt_J
    cmp bl, 'K'
    je encrypt_K
    cmp bl, 'L'
    je encrypt_L
    cmp bl, 'M'
    je encrypt_M
    cmp bl, 'N'
    je encrypt_N
    cmp bl, 'O'
    je encrypt_O
    cmp bl, 'P'
    je encrypt_P
    cmp bl, 'Q'
    je encrypt_Q
    cmp bl, 'R'
    je encrypt_R
    cmp bl, 'S'
    je encrypt_S
    cmp bl, 'T'
    je encrypt_T
    cmp bl, 'U'
    je encrypt_U
    cmp bl, 'V'
    je encrypt_V
    cmp bl, 'W'
    je encrypt_W
    cmp bl, 'X'
    je encrypt_X
    cmp bl, 'Y'
    je encrypt_Y
    cmp bl, 'Z'
    je encrypt_Z
    cmp bl, '1'
    je encrypt_1
    cmp bl, '2'
    je encrypt_2
    cmp bl, '3'
    je encrypt_3
    cmp bl, '4'
    je encrypt_4
    cmp bl, '5'
    je encrypt_5
    cmp bl, '6'
    je encrypt_6
    cmp bl, '7'
    je encrypt_7
    cmp bl, '8'
    je encrypt_8
    cmp bl, '9'
    je encrypt_9
    cmp bl, '0'
    je encrypt_0

    write_terminator: 
        dec edx
        mov DWORD [edi + 4 * edx], 0
        
        xor eax, eax
    jmp write_morse_end

    encrypt_BLANK: ; `| `
        ; mov DWORD [edi + 4 * edx], "|"
        ; inc edx
        ; mov DWORD [edi + 4 * edx], ' '
        ; inc edx

        xor eax, eax
        ; mov eax, 2
    jmp write_morse_end

    encrypt_COMMA: ; `--..-- `
        mov DWORD [edi + 4 * edx], "-"
        inc edx
        mov DWORD [edi + 4 * edx], "-"
        inc edx
        mov DWORD [edi + 4 * edx], "."
        inc edx
        mov DWORD [edi + 4 * edx], "."
        inc edx
        mov DWORD [edi + 4 * edx], "-"
        inc edx
        mov DWORD [edi + 4 * edx], "-"
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 7
    jmp write_morse_end

    encrypt_A: ; `.- `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 3
    jmp write_morse_end

    encrypt_B: ; `-... `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end

    encrypt_C: ; `-.-. `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end
    
    encrypt_D: ; `-.. `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 4
    jmp write_morse_end

    encrypt_E: ; `. `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 2
    jmp write_morse_end

    encrypt_F: ; `..-. `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end

    encrypt_G: ; `--. `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 4
    jmp write_morse_end

    encrypt_H: ; `.... `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end

    encrypt_I: ; `.. `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 3
    jmp write_morse_end

    encrypt_J: ; `.--- `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end

    encrypt_K: ; `-.- `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 4
    jmp write_morse_end

    encrypt_L: ; `.-.. `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end

    encrypt_M: ; `-- `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 3
    jmp write_morse_end

    encrypt_N: ; `-. `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 3
    jmp write_morse_end

    encrypt_O: ; `--- `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 4
    jmp write_morse_end

    encrypt_P: ; `.--. `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end

    encrypt_Q: ; `--.- `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end

    encrypt_R: ; `.-. `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 4
    jmp write_morse_end

    encrypt_S: ; `... `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 4
    jmp write_morse_end

    encrypt_T: ; `- `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 2
    jmp write_morse_end

    encrypt_U: ; `..- `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 4
    jmp write_morse_end

    encrypt_V: ; `...- `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end
    
    encrypt_W: ; `.-- `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 4
    jmp write_morse_end

    encrypt_X: ; `-..- `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end

    encrypt_Y: ; `-.-- `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end

    encrypt_Z: ; `--.. `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 5
    jmp write_morse_end

    encrypt_1: ; `.---- `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 6
    jmp write_morse_end

    encrypt_2: ; `..--- `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 6
    jmp write_morse_end

    encrypt_3: ; `...-- `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 6
    jmp write_morse_end

    encrypt_4: ; `....- `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 6
    jmp write_morse_end

    encrypt_5: ; `..... `
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 6
    jmp write_morse_end

    encrypt_6: ; `-.... `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 6
    jmp write_morse_end

    encrypt_7: ; `--... `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 6
    jmp write_morse_end

    encrypt_8: ; `---.. `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 6
    jmp write_morse_end

    encrypt_9: ; `----. `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '.'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 6
    jmp write_morse_end

    encrypt_0: ; `----- `
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], '-'
        inc edx
        mov DWORD [edi + 4 * edx], ' '
        inc edx

        xor eax, eax
        mov eax, 6
    jmp write_morse_end

    write_morse_end:
    mov esp, ebp
    pop ebp
    ret
; end write_morse

;; void morse_encrypt(int* img, char* msg, int byte_id);
morse_encrypt:
    push ebp        ; save the value of ebp
    mov ebp, esp    ; ebp now points to the top of the stack

    mov esi, [ebp + 12] ;; load msg

    xor ecx, ecx
    morse_encrypt_loop:
        xor edx, edx
        mov BYTE dl, [esi + ecx]
        cmp dl, 0
        je morse_encrypt_loop_end

        push DWORD [ebp + 16] ;; byte_id
        push DWORD [ebp + 8] ;; img
        push edx ;; char
        call write_morse
        add esp, 12
        add [ebp + 16], eax

        inc ecx
    jmp morse_encrypt_loop
    morse_encrypt_loop_end:

    push DWORD [ebp + 16] ;; byte_id
    push DWORD [ebp + 8] ;; img
    push edx ;; char
    call write_morse
    add esp, 12

    mov esp, ebp
    pop ebp
    ret
; end morse_encrypt


main:
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:
    ;; bruteforce key
    call bruteforce_singlebyte_xor
    ;; in eax is the line number
    ;; in ebx is the key found

    push eax ; save eax
    push ebx
    mov esi, [img]
    mov edi, [img_width]
    mul edi
    mov ecx, eax
    print_task1_hidden_msg:
        mov ebx, [esi + 4 * ecx]
        test ebx, ebx
        jz end_print_task1_hidden_msg
        PRINT_CHAR ebx
    inc ecx
    jmp print_task1_hidden_msg
    end_print_task1_hidden_msg:

    NEWLINE
    pop ebx
    PRINT_UDEC 1, ebx
    NEWLINE
    pop eax ; restore eax
    PRINT_UDEC 4, eax ;; IN EAX ESTE NUMARUL LINIEI
    NEWLINE

    jmp done
solve_task2:
    ; call print_matrix

    ;; bruteforce key
    call bruteforce_singlebyte_xor
    ;; in eax is the line number
    ;; in ebx is the key found

    push eax
    push ebx
    call compute_new_key
    pop ebx ; restore old key
    mov ecx, eax ; save new key in ecx
    pop eax

    inc eax ;; write text on next line
    push eax ;; second arg is the line number to insert text
    push ecx ;; first arg is the encryption key
    call write_msg_and_encode

    push DWORD [img_height]
    push DWORD [img_width]
    push DWORD [img]
    call print_image

    ; call print_matrix
    jmp done
solve_task3:
    ; call print_matrix
    ; NEWLINE

    xor eax, eax
    mov eax, [ebp + 12]
    mov ebx, [eax + 12] ; text
    lea esi, [ebx]
    ; PRINT_STRING [ebx]
    ; NEWLINE

    mov ebx, [eax + 16] ; index
    push ebx
    call atoi
    add esp, 4
    ; PRINT_UDEC 4, eax 
    ; NEWLINE

    push eax
    push esi
    push DWORD [img]
    call morse_encrypt

    push DWORD [img_height]
    push DWORD [img_width]
    push DWORD [img]
    call print_image

    ; NEWLINE
    ; call print_matrix

    jmp done
solve_task4:
    ; TODO Task4
    jmp done
solve_task5:
    ; TODO Task5
    jmp done
solve_task6:
    ; TODO Task6
    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
    
