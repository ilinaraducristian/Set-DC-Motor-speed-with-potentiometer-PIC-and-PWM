#include "p16f526.inc"

; CONFIG
; __config 0x94
        __CONFIG _FOSC_INTRC_RB4 & _WDTE_OFF & _CP_OFF & _MCLRE_OFF & _IOSCFS_4MHz & _CPDF_OFF
;END CONFIG

        org     0 ;start at 0

; VARIABLES

        counter equ     0x0d ;counter for __delay
        delay   equ     0x0e ;delay for __delay
        temp    equ     0x0f

; VARIABLES

; INITIALIZATION
;set comparator register
        clrf    CM1CON0
        clrf    CM2CON0

;set adc register
        movlw   B'01111001'
        movwf   ADCON0

;set portb tris
        movlw   b'00001100'
        tris    PORTB

;set portc tris
        clrw
        tris    PORTC

;set option register
        movlw   B'11000111'
        option

;set portb
        clrf    PORTB

;set portc
        clrf    PORTC

;set delay time: delay = round(0.0152587891 * Tms)   Tms=1000=1sec => d'15'
        movlw   d'8'
        movwf   delay

;set temp variable
        clrf    temp

; END INITTIALIZATION

mainloop:
        call    __convert_adc

        ;conversion ready
        movf    ADRES, 0 ;W = ADC result

        movwf   delay ;delay = W
        bsf     PORTC, 0 ;RC0 - HIGH
        call    __delay ;wait for 'delay' time

        movlw   d'15' ;W = 15
        movwf   temp ;temp = 15
        movf    delay, 0 ;W = delay
        subwf   temp, 0 ;W = temp - W
        movwf   delay ;delay = W
        bcf     PORTC, 0 ;RC0 - LOW
        call    __delay ;wait for 'delay' time

        goto    mainloop

__convert_adc
        bsf     ADCON0, 1 ;start conversion
__convert_adc_loop:
        btfsc   ADCON0, 1
        goto    __convert_adc_loop
        retlw   0

__delay
        clrf    TMR0 ;clear TMR0
        clrf    counter ;clear counter

__delay_loop:
        bcf     STATUS, 2 ;clear Z flag
        movlw   0xff      ;W = 0xff
        subwf   TMR0, 0   ;W = TMR0 - W
        btfss   STATUS, 2 ;check Z flag
        goto    __delay_loop

        clrf    TMR0 ;clear TMR0

        bcf     STATUS, 2 ;clear Z flag
        movf    counter, 0 ;W = counter
        subwf   delay, 0 ;W = delay - W
        btfsc   STATUS, 2 ;check Z flag
        retlw   0
        
        incf    counter, 1 ;counter++
        goto    __delay_loop

end
