#include "p18f8722.inc"
; CONFIG1H
  CONFIG  OSC = HSPLL, FCMEN = OFF, IESO = OFF
; CONFIG2L
  CONFIG  PWRT = OFF, BOREN = OFF, BORV = 3
; CONFIG2H
  CONFIG  WDT = OFF, WDTPS = 32768
; CONFIG3L
  CONFIG  MODE = MC, ADDRBW = ADDR20BIT, DATABW = DATA16BIT, WAIT = OFF
; CONFIG3H
  CONFIG  CCP2MX = PORTC, ECCPMX = PORTE, LPT1OSC = OFF, MCLRE = ON
; CONFIG4L
  CONFIG  STVREN = ON, LVP = OFF, BBSIZ = BB2K, XINST = OFF
; CONFIG5L
  CONFIG  CP0 = OFF, CP1 = OFF, CP2 = OFF, CP3 = OFF, CP4 = OFF, CP5 = OFF
  CONFIG  CP6 = OFF, CP7 = OFF
; CONFIG5H
  CONFIG  CPB = OFF, CPD = OFF
; CONFIG6L
  CONFIG  WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRT3 = OFF, WRT4 = OFF
  CONFIG  WRT5 = OFF, WRT6 = OFF, WRT7 = OFF
; CONFIG6H
  CONFIG  WRTC = OFF, WRTB = OFF, WRTD = OFF
; CONFIG7L
  CONFIG  EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF, EBTR4 = OFF
  CONFIG  EBTR5 = OFF, EBTR6 = OFF, EBTR7 = OFF
; CONFIG7H
  CONFIG  EBTRB = OFF

;*******************************************************************************
; Variables & Constants
;*******************************************************************************
UDATA_ACS
  t1  res 1 ; used in delay
  t2  res 1 ; used in delay
  t3  res 1 ; used in delay
  state res 1 ; controlled by RB0 button
  snake_position equ h'0';
;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE  ; let linker place main program


START
    call INIT ; initialize variables and ports
    call DELAY  ; wait a second
    call MAIN_LOOP

Move_cw_2 ; called after initial loop
  CALL DELAY

  BSF LATD, 0
  CALL DELAY


BUTTON_TASK ; very primitive button task
      BTFSS PORTB,5
      goto BUTTON_TASK

      _debounce:
      BTFSC PORTB,5
      goto _debounce    ; busy waiting. FIXME !!!
      ;COMF state, 1
      return

Move_cw

    INCF snake_position, 1
    BTFSS snake_position, 1
    GOTO pos1
    pos1:
        BCF LATD, 2
        BSF LATD, 0
        BSF LATD, 1
        call DELAY  ; wait a second

    BTFSS snake_position, 2
    GOTO pos2
    pos2:
        BCF LATD, 0
        BSF LATD, 1
        BSF LATD, 2
        call DELAY  ; wait a second

    BTFSS snake_position, 3
    GOTO pos3
    pos3:
        BCF LATD, 1
        BSF LATD, 2
        BSF LATD, 3
        call DELAY  ; wait a second
        CALL BUTTON_TASK

    BTFSS snake_position, 4
    GOTO pos4
    pos4:
        BCF LATD, 2
        BSF LATD, 3
        BSF LATC, 0
        call DELAY  ; wait a second

    BTFSS snake_position, 5
    GOTO pos5
    pos5:
        BCF LATD, 3
        BSF LATC, 0
        BSF LATC, 1
        call DELAY  ; wait a second

    BTFSS snake_position, 6
    GOTO pos6
    pos6:
        BCF LATC, 0
        BSF LATC, 1
        BSF LATC, 2
        call DELAY  ; wait a second

    BTFSS snake_position, 7
    GOTO pos7
    pos7:
        BCF LATC, 1
        BSF LATC, 2
        BSF LATC, 3
        call DELAY  ; wait a second

    BTFSS snake_position, 8
    GOTO pos8
    pos8:
        BCF LATC, 2
        BSF LATC, 3
        BSF LATB, 0
        call DELAY  ; wait a second

    BTFSS snake_position, 9
    GOTO pos9
    pos9:
        BCF LATC, 3
        BSF LATB, 0
        BSF LATB, 1
        call DELAY  ; wait a second

    BTFSS snake_position, A
    GOTO pos10
    pos10:
        BCF LATB, 0
        BSF LATB, 1
        BSF LATB, 2
        call DELAY  ; wait a second

    BTFSS snake_position, h'B'
    GOTO pos11
    pos11:
        BCF LATB, 1
        BSF LATB, 2
        BSF LATB, 3
        call DELAY  ; wait a second


    BTFSS snake_position, h'C'
    GOTO pos12
    pos12:
        BCF LATB, 2
        BSF LATB, 3
        BSF LATA, 0
        call DELAY  ; wait a second


    BTFSS snake_position, h'D'
    GOTO pos13
    pos13:
        BCF LATB, 3
        BSF LATA, 0
        BSF LATA, 1
        call DELAY  ; wait a second


    BTFSS snake_position, h'E'
    GOTO pos14
    pos14:
        BCF LATA, 0
        BSF LATA, 1
        BSF LATA, 2
        call DELAY  ; wait a second

    BTFSS snake_position, h'F'
    GOTO pos15
    pos15:
        BCF LATA, 1
        BSF LATA, 2
        BSF LATA, 3
        call DELAY  ; wait a second
        BCF LATA, 2
        call DELAY  ; wait a second
        BCF LATA, 3


MAIN_LOOP

    ;BTFSS snake_position, h'F'
    ;GOTO not_initial_loop

    CALL Move_cw

    not_initial_loop:
        CALL Move_cw_2

    GOTO MAIN_LOOP  ; loop forever


DELAY ; Time Delay Routine with 3 nested loops
    MOVLW 18  ; Copy desired value to W
    MOVWF t3  ; Copy W into t3
    _loop3:
  MOVLW 0xA0  ; Copy desired value to W
  MOVWF t2    ; Copy W into t2
  _loop2:
      MOVLW 0x9F  ; Copy desired value to W
      MOVWF t1  ; Copy W into t1
      _loop1:
    decfsz t1,F ; Decrement t1. If 0 Skip next instruction
    GOTO _loop1 ; ELSE Keep counting down
    decfsz t2,F ; Decrement t2. If 0 Skip next instruction
    GOTO _loop2 ; ELSE Keep counting down
    decfsz t3,F ; Decrement t3. If 0 Skip next instruction
    GOTO _loop3 ; ELSE Keep counting down
    return


INIT

MOVLW 0Fh
MOVWF ADCON1

    MOVLW   0xF0
    MOVWF    TRISA
    MOVWF    TRISB
    MOVWF    TRISC
    MOVWF    TRISD

    CLRF    state
    MOVLW   0xFF
    CLRF    LATB

    MOVWF   LATC
    MOVWF   LATD
    MOVWF   LATA
    MOVWF   LATB
    CALL DELAY
    CALL DELAY

    CLRF   LATC
    CLRF   LATD
    CLRF   LATA
    CLRF   LATB



    ;MOVWF   LATE
    ;MOVWF   LATF
    ;CLRF    LATG
    ;MOVWF   LATH    ; selects display permutation
    ;MOVWF   LATJ    ; on/off segment in a display

 

    return







  COMF state, 1

  return


TABLE
    MOVF    PCL, F  ; A simple read of PCL will update PCLATH, PCLATU
    RLNCF   WREG, W ; multiply index X2
    ADDWF   PCL, F  ; modify program counter
    RETLW b'00111111' ;0 representation in 7-seg. disp. portJ
    RETLW b'00000110' ;1 representation in 7-seg. disp. portJ
    RETLW b'01011011' ;2 representation in 7-seg. disp. portJ
    RETLW b'01001111' ;3 representation in 7-seg. disp. portJ
    RETLW b'01100110' ;4 representation in 7-seg. disp. portJ
    RETLW b'01101101' ;5 representation in 7-seg. disp. portJ
    RETLW b'01111101' ;6 representation in 7-seg. disp. portJ
    RETLW b'00000111' ;7 representation in 7-seg. disp. portJ
    RETLW b'01111111' ;8 representation in 7-seg. disp. portJ
    RETLW b'01100111' ;9 representation in 7-seg. disp. portJ


END