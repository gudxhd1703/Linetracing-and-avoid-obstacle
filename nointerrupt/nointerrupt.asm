
;CodeVisionAVR C Compiler V3.51 Evaluation
;(C) Copyright 1998-2023 Pavel Haiduc, HP InfoTech S.R.L.
;http://www.hpinfotech.ro

;Build configuration    : Debug
;Chip type              : ATmega2560
;Program type           : Application
;Clock frequency        : 16.000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 2048 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': No
;'char' is unsigned     : Yes
;8 bit enums            : No
;Global 'const' stored in FLASH: No
;Enhanced function parameter passing: Mode 2
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATmega2560
	#pragma AVRPART MEMORY PROG_FLASH 262144
	#pragma AVRPART MEMORY EEPROM 4096
	#pragma AVRPART MEMORY INT_SRAM SIZE 8192
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x200

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU EECR=0x1F
	.EQU EEDR=0x20
	.EQU EEARL=0x21
	.EQU EEARH=0x22
	.EQU SPSR=0x2D
	.EQU SPDR=0x2E
	.EQU SMCR=0x33
	.EQU MCUSR=0x34
	.EQU MCUCR=0x35
	.EQU WDTCSR=0x60
	.EQU UCSR0A=0xC0
	.EQU UDR0=0xC6
	.EQU SPMCSR=0x37
	.EQU RAMPZ=0x3B
	.EQU EIND=0x3C
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU XMCRA=0x74
	.EQU XMCRB=0x75
	.EQU GPIOR0=0x1E

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0200
	.EQU __SRAM_END=0x21FF
	.EQU __DSTACK_SIZE=0x0800
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.EQU __FLASH_PAGE_SIZE=0x80
	.EQU __EEPROM_PAGE_SIZE=0x08

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETW1P
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __GETD1P_INC
	LD   R30,X+
	LD   R31,X+
	LD   R22,X+
	LD   R23,X+
	.ENDM

	.MACRO __GETD1P_DEC
	LD   R23,-X
	LD   R22,-X
	LD   R31,-X
	LD   R30,-X
	.ENDM

	.MACRO __PUTDP1
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTDP1_DEC
	ST   -X,R23
	ST   -X,R22
	ST   -X,R31
	ST   -X,R30
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __CPD10
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	.ENDM

	.MACRO __CPD20
	SBIW R26,0
	SBCI R24,0
	SBCI R25,0
	.ENDM

	.MACRO __ADDD12
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	ADC  R23,R25
	.ENDM

	.MACRO __ADDD21
	ADD  R26,R30
	ADC  R27,R31
	ADC  R24,R22
	ADC  R25,R23
	.ENDM

	.MACRO __SUBD12
	SUB  R30,R26
	SBC  R31,R27
	SBC  R22,R24
	SBC  R23,R25
	.ENDM

	.MACRO __SUBD21
	SUB  R26,R30
	SBC  R27,R31
	SBC  R24,R22
	SBC  R25,R23
	.ENDM

	.MACRO __ANDD12
	AND  R30,R26
	AND  R31,R27
	AND  R22,R24
	AND  R23,R25
	.ENDM

	.MACRO __ORD12
	OR   R30,R26
	OR   R31,R27
	OR   R22,R24
	OR   R23,R25
	.ENDM

	.MACRO __XORD12
	EOR  R30,R26
	EOR  R31,R27
	EOR  R22,R24
	EOR  R23,R25
	.ENDM

	.MACRO __XORD21
	EOR  R26,R30
	EOR  R27,R31
	EOR  R24,R22
	EOR  R25,R23
	.ENDM

	.MACRO __COMD1
	COM  R30
	COM  R31
	COM  R22
	COM  R23
	.ENDM

	.MACRO __MULD2_2
	LSL  R26
	ROL  R27
	ROL  R24
	ROL  R25
	.ENDM

	.MACRO __LSRD1
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	.ENDM

	.MACRO __LSLD1
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	.ENDM

	.MACRO __ASRB4
	ASR  R30
	ASR  R30
	ASR  R30
	ASR  R30
	.ENDM

	.MACRO __ASRW8
	MOV  R30,R31
	CLR  R31
	SBRC R30,7
	SER  R31
	.ENDM

	.MACRO __LSRD16
	MOV  R30,R22
	MOV  R31,R23
	LDI  R22,0
	LDI  R23,0
	.ENDM

	.MACRO __LSLD16
	MOV  R22,R30
	MOV  R23,R31
	LDI  R30,0
	LDI  R31,0
	.ENDM

	.MACRO __CWD1
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	.ENDM

	.MACRO __CWD2
	MOV  R24,R27
	ADD  R24,R24
	SBC  R24,R24
	MOV  R25,R24
	.ENDM

	.MACRO __SETMSD1
	SER  R31
	SER  R22
	SER  R23
	.ENDM

	.MACRO __ADDW1R15
	CLR  R0
	ADD  R30,R15
	ADC  R31,R0
	.ENDM

	.MACRO __ADDW2R15
	CLR  R0
	ADD  R26,R15
	ADC  R27,R0
	.ENDM

	.MACRO __EQB12
	CP   R30,R26
	LDI  R30,1
	BREQ PC+2
	CLR  R30
	.ENDM

	.MACRO __NEB12
	CP   R30,R26
	LDI  R30,1
	BRNE PC+2
	CLR  R30
	.ENDM

	.MACRO __LEB12
	CP   R30,R26
	LDI  R30,1
	BRGE PC+2
	CLR  R30
	.ENDM

	.MACRO __GEB12
	CP   R26,R30
	LDI  R30,1
	BRGE PC+2
	CLR  R30
	.ENDM

	.MACRO __LTB12
	CP   R26,R30
	LDI  R30,1
	BRLT PC+2
	CLR  R30
	.ENDM

	.MACRO __GTB12
	CP   R30,R26
	LDI  R30,1
	BRLT PC+2
	CLR  R30
	.ENDM

	.MACRO __LEB12U
	CP   R30,R26
	LDI  R30,1
	BRSH PC+2
	CLR  R30
	.ENDM

	.MACRO __GEB12U
	CP   R26,R30
	LDI  R30,1
	BRSH PC+2
	CLR  R30
	.ENDM

	.MACRO __LTB12U
	CP   R26,R30
	LDI  R30,1
	BRLO PC+2
	CLR  R30
	.ENDM

	.MACRO __GTB12U
	CP   R30,R26
	LDI  R30,1
	BRLO PC+2
	CLR  R30
	.ENDM

	.MACRO __CPW01
	CLR  R0
	CP   R0,R30
	CPC  R0,R31
	.ENDM

	.MACRO __CPW02
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	.ENDM

	.MACRO __CPD12
	CP   R30,R26
	CPC  R31,R27
	CPC  R22,R24
	CPC  R23,R25
	.ENDM

	.MACRO __CPD21
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R25,R23
	.ENDM

	.MACRO __BSTB1
	CLT
	TST  R30
	BREQ PC+2
	SET
	.ENDM

	.MACRO __LNEGB1
	TST  R30
	LDI  R30,1
	BREQ PC+2
	CLR  R30
	.ENDM

	.MACRO __LNEGW1
	OR   R30,R31
	LDI  R30,1
	BREQ PC+2
	LDI  R30,0
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD2M
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	PUSH R26
	PUSH R27
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	POP  R27
	POP  R26
	ICALL
	.ENDM

	.MACRO __CALL2EX
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __EEPROMRDD
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z
	MOVW R30,R0
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CALL __GETW1Z
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	CALL __GETD1Z
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __GETW2X
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __GETD2X
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _control=R3
	.DEF _control_msb=R4
	.DEF _check_flag=R5
	.DEF _check_flag_msb=R6
	.DEF _find_line=R7
	.DEF _find_line_msb=R8

;GPIOR0 INITIALIZATION VALUE
	.EQU __GPIOR0_INIT=0x00

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer1_ovf_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

;GLOBAL REGISTER VARIABLES INITIALIZATION
__REG_VARS:
	.DB  0x1,0x0,0x0,0x0

_0x3:
	.DB  0x76,0x0,0xF0,0x0,0xF0
_0x4:
	.DB  0xF7,0x0,0xEF,0x0,0xE7,0x0,0xCF,0x0
	.DB  0xF3,0x0,0xC7,0x0,0xE3,0x0,0xFD,0x0
	.DB  0xFB,0x0,0xF9,0x0,0xF1,0x0,0xFE,0x0
	.DB  0xFC,0x0,0xBF,0x0,0xDF,0x0,0x9F,0x0
	.DB  0x8F,0x0,0x7F,0x0,0x3F
_0x5:
	.DB  0x58,0x0,0x6C,0x0,0x67,0x0,0x56,0x0
	.DB  0x55,0x0,0x4A,0x0,0x51,0x0,0x49

__GLOBAL_INI_TBL:
	.DW  0x04
	.DW  0x03
	.DW  __REG_VARS*2

	.DW  0x05
	.DW  _Tx_buf1
	.DW  _0x3*2

	.DW  0x25
	.DW  _Infrared_Sensor
	.DW  _0x4*2

	.DW  0x0F
	.DW  _Compare_Value
	.DW  _0x5*2

_0xFFFFFFFF:
	.DW  0

#define __GLOBAL_INI_TBL_PRESENT 1

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30
	STS  XMCRA,R30
	STS  XMCRB,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

	OUT  RAMPZ,R24

	OUT  EIND,R24

;GPIOR0 INITIALIZATION
	LDI  R30,__GPIOR0_INIT
	OUT  GPIOR0,R30

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0x00

	.DSEG
	.ORG 0xA00

	.CSEG
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.EQU __sm_adc_noise_red=0x02
	.SET power_ctrl_reg=smcr
	#endif
;void DAC_CH_Write(unsigned int, unsigned int);
;void DAC_setting(unsigned int);
;void Initial_Motor_Setting(void);
;void Init_USART(void);
;void Stop_Setting(void);
;void Motor_dir(int c);
;void Linetracer(void);
;void Emergency_Act(void);
;void Serial_Send0(unsigned char);
;void SerialData0(char *str);
;unsigned char Serial_Rece1(void);
;void Ult_Sonic(void);

	.DSEG
;void DAC_CH_Write(unsigned int ch1, unsigned int da)
; 0000 0044 {

	.CSEG
_DAC_CH_Write:
; .FSTART _DAC_CH_Write
; 0000 0045 unsigned int data = ((ch1 << 12) & 0x7000) | ((da << 4) & 0x0ff0);
; 0000 0046 DAC_setting(data);
	ST   -Y,R27
	ST   -Y,R26
	RCALL __SAVELOCR4
	__GETWRS 18,19,6
;	ch1 -> R18,R19
;	da -> Y+4
;	data -> R16,R17
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(12)
	RCALL __LSLW12
	ANDI R30,LOW(0x7000)
	ANDI R31,HIGH(0x7000)
	MOVW R26,R30
	LDD  R30,Y+4
	LDD  R31,Y+4+1
	RCALL __LSLW4
	ANDI R30,LOW(0xFF0)
	ANDI R31,HIGH(0xFF0)
	OR   R30,R26
	OR   R31,R27
	MOVW R16,R30
	MOVW R26,R16
	RCALL _DAC_setting
; 0000 0047 }
	RCALL __LOADLOCR4
	ADIW R28,8
	RET
; .FEND
;void DAC_setting(unsigned int data)
; 0000 004A {
_DAC_setting:
; .FSTART _DAC_setting
; 0000 004B unsigned char S_DIN = clear; // PL7 초기화
; 0000 004C int i = 0;
; 0000 004D 
; 0000 004E PORTL = PORTL | 0x40; // S_CLK = 0
	RCALL __SAVELOCR6
	MOVW R20,R26
;	data -> R20,R21
;	S_DIN -> R17
;	i -> R18,R19
	LDI  R17,0
	__GETWRN 18,19,0
	RCALL SUBOPT_0x0
; 0000 004F delay_us(1);
; 0000 0050 
; 0000 0051 PORTL = PORTL & 0xbf; // S_CLK = 1   falling_edge
; 0000 0052 delay_us(1);
; 0000 0053 
; 0000 0054 PORTL = PORTL & 0xdf; // sycn' = 1
	LDS  R30,267
	ANDI R30,0xDF
	STS  267,R30
; 0000 0055 delay_us(1);
	__DELAY_USB 5
; 0000 0056 
; 0000 0057 for (i = 16; i > 0; i--)
	__GETWRN 18,19,16
_0x7:
	CLR  R0
	CP   R0,R18
	CPC  R0,R19
	BRGE _0x8
; 0000 0058 {
; 0000 0059 S_DIN = (data >> (i - 1)) & 0x01; // MSB에서 LSB로 이동시며 데이터를 S_DIN에 저장하여 확인한다.
	MOV  R30,R18
	SUBI R30,LOW(1)
	MOVW R26,R20
	RCALL __LSRW12
	ANDI R30,LOW(0x1)
	MOV  R17,R30
; 0000 005A 
; 0000 005B if (S_DIN == 1)
	CPI  R17,1
	BRNE _0x9
; 0000 005C PORTL = PORTL | 0x80;
	LDS  R30,267
	ORI  R30,0x80
	RJMP _0x95
; 0000 005D else if (S_DIN == 0)
_0x9:
	CPI  R17,0
	BRNE _0xB
; 0000 005E PORTL = PORTL & 0x7f;
	LDS  R30,267
	ANDI R30,0x7F
_0x95:
	STS  267,R30
; 0000 005F 
; 0000 0060 PORTL = PORTL | 0x40; // S_CLK = 1
_0xB:
	RCALL SUBOPT_0x0
; 0000 0061 delay_us(1);
; 0000 0062 
; 0000 0063 PORTL = PORTL & 0xbf; // S_CLK = 0
; 0000 0064 delay_us(1);
; 0000 0065 }
	__SUBWRN 18,19,1
	RJMP _0x7
_0x8:
; 0000 0066 PORTL = PORTL | 0x20; // sync' = 1
	RCALL SUBOPT_0x1
; 0000 0067 }
	RJMP _0x2000003
; .FEND
;void Initial_Motor_Setting(void)
; 0000 006A {
_Initial_Motor_Setting:
; .FSTART _Initial_Motor_Setting
; 0000 006B 
; 0000 006C int i = 0;
; 0000 006D 
; 0000 006E DDRA = DDRA | 0x1f; // 적외선 발광다이오드 구동 및  모터드라이버
	ST   -Y,R17
	ST   -Y,R16
;	i -> R16,R17
	__GETWRN 16,17,0
	IN   R30,0x1
	ORI  R30,LOW(0x1F)
	OUT  0x1,R30
; 0000 006F DDRC = 0x00;        // Digtial Input
	LDI  R30,LOW(0)
	OUT  0x7,R30
; 0000 0070 DDRL = 0xe0;        // serial
	LDI  R30,LOW(224)
	STS  266,R30
; 0000 0071 
; 0000 0072 PORTL = PORTL & 0xbf; // s_clk = 0
	LDS  R30,267
	ANDI R30,0xBF
	STS  267,R30
; 0000 0073 PORTL = PORTL | 0x20; // sycn' = 1
	RCALL SUBOPT_0x1
; 0000 0074 
; 0000 0075 PORTA = PORTA | 0x10; // 적외선 발광다이오드 ON
	SBI  0x2,4
; 0000 0076 DDRG = DDRG | 0x20;   // 왼쪽모터 Enable단자 출력으로 초기화
	SBI  0x13,5
; 0000 0077 DDRE = DDRE | 0x08;   // PE3 PWM신호로 설정
	SBI  0xD,3
; 0000 0078 
; 0000 0079 PORTG = clear;
	LDI  R30,LOW(0)
	OUT  0x14,R30
; 0000 007A PORTE = clear;
	OUT  0xE,R30
; 0000 007B 
; 0000 007C TCCR0A = 0x21; // PWM Phase correct mode로 사용, compare match모드
	LDI  R30,LOW(33)
	OUT  0x24,R30
; 0000 007D TCCR0B = 0x05; // 업카운트시 TCNTO와 OCR0가 일치하면 OCR0 clear 하향카운트시에 일치하면 SET
	LDI  R30,LOW(5)
	OUT  0x25,R30
; 0000 007E TCNT0 = clear;
	LDI  R30,LOW(0)
	OUT  0x26,R30
; 0000 007F 
; 0000 0080 RIGHT = clear; // 왼쪽바퀴 pwm시간 입력
	OUT  0x28,R30
; 0000 0081 
; 0000 0082 TCCR3A = 0x81; // 8비트 모드의 phase corrct pwm 모드로 동작
	LDI  R30,LOW(129)
	STS  144,R30
; 0000 0083 TCCR3B = 0x05; // compare match 상향카운터 OC3A를 클리어 하향카운터에서 set
	LDI  R30,LOW(5)
	STS  145,R30
; 0000 0084 
; 0000 0085 TCNT3L = clear;
	LDI  R30,LOW(0)
	STS  148,R30
; 0000 0086 TCNT3H = clear;
	STS  149,R30
; 0000 0087 
; 0000 0088 OCR3AH = clear; // 오른쪽바퀴 High bit clear
	STS  153,R30
; 0000 0089 LEFT = clear;   // 오른쪽바퀴 Low bit clear
	STS  152,R30
; 0000 008A 
; 0000 008B DAC_setting(0x9000);
	LDI  R26,LOW(36864)
	LDI  R27,HIGH(36864)
	RCALL _DAC_setting
; 0000 008C 
; 0000 008D for (i = 0; i < 8; i++)
	__GETWRN 16,17,0
_0xD:
	__CPWRN 16,17,8
	BRGE _0xE
; 0000 008E {
; 0000 008F DAC_CH_Write(i, Compare_Value[i]);
	ST   -Y,R17
	ST   -Y,R16
	MOVW R30,R16
	LDI  R26,LOW(_Compare_Value)
	LDI  R27,HIGH(_Compare_Value)
	RCALL SUBOPT_0x2
	MOVW R26,R30
	RCALL _DAC_CH_Write
; 0000 0090 }
	__ADDWRN 16,17,1
	RJMP _0xD
_0xE:
; 0000 0091 
; 0000 0092 delay_ms(20);
	LDI  R26,LOW(20)
	LDI  R27,0
	RCALL _delay_ms
; 0000 0093 }
	RJMP _0x2000001
; .FEND
;void Motor_dir(int c)
; 0000 0096 {
_Motor_dir:
; .FSTART _Motor_dir
; 0000 0097 
; 0000 0098 switch (c)
	ST   -Y,R17
	ST   -Y,R16
	MOVW R16,R26
;	c -> R16,R17
	MOVW R30,R16
; 0000 0099 { // F = Forward , L = Left, R = Right
; 0000 009A case F:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x12
; 0000 009B LEFT_MD_A = 1;
	SBI  0x2,0
; 0000 009C LEFT_MD_B = 0;
	CBI  0x2,1
; 0000 009D L_MOTOR_EN = 1;
	SBI  0x14,5
; 0000 009E RIGHT_MD_A = 0;
	CBI  0x2,2
; 0000 009F RIGHT_MD_B = 1;
	SBI  0x2,3
; 0000 00A0 R_MOTOR_EN = 1;
	RJMP _0x96
; 0000 00A1 break;
; 0000 00A2 case L:
_0x12:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x1F
; 0000 00A3 LEFT_MD_A = 0;
	CBI  0x2,0
; 0000 00A4 LEFT_MD_B = 1;
	SBI  0x2,1
; 0000 00A5 L_MOTOR_EN = 1;
	SBI  0x14,5
; 0000 00A6 RIGHT_MD_A = 0;
	CBI  0x2,2
; 0000 00A7 RIGHT_MD_B = 1;
	SBI  0x2,3
; 0000 00A8 R_MOTOR_EN = 1;
	RJMP _0x96
; 0000 00A9 break;
; 0000 00AA case R:
_0x1F:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BREQ _0x97
; 0000 00AB LEFT_MD_A = 1;
; 0000 00AC LEFT_MD_B = 0;
; 0000 00AD L_MOTOR_EN = 1;
; 0000 00AE RIGHT_MD_A = 1;
; 0000 00AF RIGHT_MD_B = 0;
; 0000 00B0 R_MOTOR_EN = 1;
; 0000 00B1 break;
; 0000 00B2 case S:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x39
; 0000 00B3 LEFT_MD_A = 0;
	CBI  0x2,0
; 0000 00B4 LEFT_MD_B = 0;
	CBI  0x2,1
; 0000 00B5 L_MOTOR_EN = 1;
	SBI  0x14,5
; 0000 00B6 RIGHT_MD_A = 0;
	CBI  0x2,2
; 0000 00B7 RIGHT_MD_B = 0;
	RJMP _0x98
; 0000 00B8 R_MOTOR_EN = 1;
; 0000 00B9 break;
; 0000 00BA case T:
_0x39:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x11
; 0000 00BB LEFT_MD_A = 1;
_0x97:
	SBI  0x2,0
; 0000 00BC LEFT_MD_B = 0;
	CBI  0x2,1
; 0000 00BD L_MOTOR_EN = 1;
	SBI  0x14,5
; 0000 00BE RIGHT_MD_A = 1;
	SBI  0x2,2
; 0000 00BF RIGHT_MD_B = 0;
_0x98:
	CBI  0x2,3
; 0000 00C0 R_MOTOR_EN = 1;
_0x96:
	SBI  0xE,3
; 0000 00C1 break;
; 0000 00C2 }
_0x11:
; 0000 00C3 }
	RJMP _0x2000001
; .FEND
;void Linetracer(void)
; 0000 00C6 {
_Linetracer:
; .FSTART _Linetracer
; 0000 00C7 
; 0000 00C8 int i, data = 0;
; 0000 00C9 unsigned char IR = 0;
; 0000 00CA 
; 0000 00CB IR = PINC;
	RCALL __SAVELOCR6
;	i -> R16,R17
;	data -> R18,R19
;	IR -> R21
	__GETWRN 18,19,0
	LDI  R21,0
	IN   R21,6
; 0000 00CC 
; 0000 00CD delay_ms(5);
	LDI  R26,LOW(5)
	LDI  R27,0
	RCALL _delay_ms
; 0000 00CE 
; 0000 00CF for (i = 0; i < 20; i++)
	__GETWRN 16,17,0
_0x54:
	__CPWRN 16,17,20
	BRGE _0x55
; 0000 00D0 {
; 0000 00D1 if (IR == Infrared_Sensor[i])
	MOVW R30,R16
	LDI  R26,LOW(_Infrared_Sensor)
	LDI  R27,HIGH(_Infrared_Sensor)
	RCALL SUBOPT_0x2
	MOV  R26,R21
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BRNE _0x56
; 0000 00D2 {
; 0000 00D3 data = i;
	MOVW R18,R16
; 0000 00D4 break;
	RJMP _0x55
; 0000 00D5 }
; 0000 00D6 }
_0x56:
	__ADDWRN 16,17,1
	RJMP _0x54
_0x55:
; 0000 00D7 
; 0000 00D8 Motor_dir(S);   //역기전력 방지
	LDI  R26,LOW(4)
	LDI  R27,0
	RCALL _Motor_dir
; 0000 00D9 
; 0000 00DA if (data < 7)
	__CPWRN 18,19,7
	BRGE _0x57
; 0000 00DB {
; 0000 00DC Motor_dir(F);
	LDI  R26,LOW(1)
	LDI  R27,0
	RCALL _Motor_dir
; 0000 00DD RIGHT = Velocity_Forward;
	LDI  R30,LOW(40)
	OUT  0x28,R30
; 0000 00DE LEFT = Velocity_Forward;
	STS  152,R30
; 0000 00DF }
; 0000 00E0 else if (data < 11)
	RJMP _0x58
_0x57:
	__CPWRN 18,19,11
	BRGE _0x59
; 0000 00E1 {
; 0000 00E2 Motor_dir(L);
	LDI  R26,LOW(2)
	RCALL SUBOPT_0x3
; 0000 00E3 RIGHT = Velocity_Low;
; 0000 00E4 LEFT = Velocity_Low;
; 0000 00E5 }
; 0000 00E6 else if (data < 13)
	RJMP _0x5A
_0x59:
	__CPWRN 18,19,13
	BRGE _0x5B
; 0000 00E7 {
; 0000 00E8 Motor_dir(L);
	LDI  R26,LOW(2)
	RCALL SUBOPT_0x4
; 0000 00E9 RIGHT = Velocity_High;
; 0000 00EA LEFT = Velocity_High;
; 0000 00EB }
; 0000 00EC else if (data < 17)
	RJMP _0x5C
_0x5B:
	__CPWRN 18,19,17
	BRGE _0x5D
; 0000 00ED {
; 0000 00EE Motor_dir(R);
	LDI  R26,LOW(3)
	RCALL SUBOPT_0x3
; 0000 00EF RIGHT = Velocity_Low;
; 0000 00F0 LEFT = Velocity_Low;
; 0000 00F1 }
; 0000 00F2 else if (data < 19)
	RJMP _0x5E
_0x5D:
	__CPWRN 18,19,19
	BRGE _0x5F
; 0000 00F3 {
; 0000 00F4 Motor_dir(R);
	LDI  R26,LOW(3)
	RCALL SUBOPT_0x4
; 0000 00F5 RIGHT = Velocity_High;
; 0000 00F6 LEFT = Velocity_High;
; 0000 00F7 }
; 0000 00F8 else if (data == 19)
	RJMP _0x60
_0x5F:
	LDI  R30,LOW(19)
	LDI  R31,HIGH(19)
	CP   R30,R18
	CPC  R31,R19
	BRNE _0x61
; 0000 00F9 {
; 0000 00FA Stop_Setting();
	RCALL _Stop_Setting
; 0000 00FB PORTH = PORTH | 0x40;
	RCALL SUBOPT_0x5
; 0000 00FC PORTL = PORTL | 0x10;
; 0000 00FD PORTB = PORTB | 0x10;
	SBI  0x5,4
; 0000 00FE control = THE_END;
	LDI  R30,LOW(4444)
	LDI  R31,HIGH(4444)
	__PUTW1R 3,4
; 0000 00FF }
; 0000 0100 }
_0x61:
_0x60:
_0x5E:
_0x5C:
_0x5A:
_0x58:
_0x2000003:
	RCALL __LOADLOCR6
	ADIW R28,6
	RET
; .FEND
;void Init_USART(void)
; 0000 0102 { // Init_USART
_Init_USART:
; .FSTART _Init_USART
; 0000 0103 
; 0000 0104 // 시리얼 포트 0는 블루투스와의 통신 포트이다
; 0000 0105 DDRE = 0xfe;
	LDI  R30,LOW(254)
	OUT  0xD,R30
; 0000 0106 UCSR0A = 0x00;
	LDI  R30,LOW(0)
	STS  192,R30
; 0000 0107 UCSR0B = 0x18; // TXE, RXE Enable
	LDI  R30,LOW(24)
	STS  193,R30
; 0000 0108 UCSR0C = 0x06; // 비동기, Non Parity, 1 Stop Bit
	LDI  R30,LOW(6)
	STS  194,R30
; 0000 0109 UBRR0H = 0x00;
	LDI  R30,LOW(0)
	STS  197,R30
; 0000 010A UBRR0L = 0x08; // 115200bps
	LDI  R30,LOW(8)
	STS  196,R30
; 0000 010B 
; 0000 010C // 시리얼 포트 1은 초음파 센서 모듈과의 통신 포트이다
; 0000 010D DDRD = 0x08;
	OUT  0xA,R30
; 0000 010E UCSR1A = 0x00;
	LDI  R30,LOW(0)
	STS  200,R30
; 0000 010F UCSR1B = 0x18; // TXE, RXE Enable
	LDI  R30,LOW(24)
	STS  201,R30
; 0000 0110 UCSR1C = 0x06; // 비동기, Non Parity, 1 Stop Bit
	LDI  R30,LOW(6)
	STS  202,R30
; 0000 0111 UBRR1H = 0x00;
	LDI  R30,LOW(0)
	STS  205,R30
; 0000 0112 UBRR1L = 0x08; // 115200 bps
	LDI  R30,LOW(8)
	STS  204,R30
; 0000 0113 DDRB = 0xff;
	LDI  R30,LOW(255)
	OUT  0x4,R30
; 0000 0114 }
	RET
; .FEND
;void Serial_Send0(unsigned char t)
; 0000 0118 {
_Serial_Send0:
; .FSTART _Serial_Send0
; 0000 0119 // 전송 준비가 될 때 까지 대기
; 0000 011A while (1)
	ST   -Y,R17
	MOV  R17,R26
;	t -> R17
_0x62:
; 0000 011B {
; 0000 011C if ((UCSR0A & 0x20) != 0)
	LDS  R30,192
	ANDI R30,LOW(0x20)
	BREQ _0x62
; 0000 011D break;
; 0000 011E }
; 0000 011F 
; 0000 0120 UDR0 = t;
	STS  198,R17
; 0000 0121 UCSR0A = UCSR0A | 0x20;
	LDS  R30,192
	ORI  R30,0x20
	STS  192,R30
; 0000 0122 }
	RJMP _0x2000002
; .FEND
;void SerialData0(char *str)
; 0000 0126 {
; 0000 0127 while (*str)
;	*str -> R16,R17
; 0000 0128 Serial_Send0(*str++);
; 0000 0129 }
;void Serial_Send1(unsigned char t)
; 0000 012C {
_Serial_Send1:
; .FSTART _Serial_Send1
; 0000 012D // 전송준비가 될 때 까지 대기
; 0000 012E while (1)
	ST   -Y,R17
	MOV  R17,R26
;	t -> R17
_0x69:
; 0000 012F {
; 0000 0130 if ((UCSR1A & 0x20) != 0)
	LDS  R30,200
	ANDI R30,LOW(0x20)
	BREQ _0x69
; 0000 0131 break;
; 0000 0132 }
; 0000 0133 UDR1 = t;
	STS  206,R17
; 0000 0134 UCSR1A = UCSR1A | 0x20;
	LDS  R30,200
	ORI  R30,0x20
	STS  200,R30
; 0000 0135 }
	RJMP _0x2000002
; .FEND
;unsigned char Serial_Rece1(void)
; 0000 0138 {
_Serial_Rece1:
; .FSTART _Serial_Rece1
; 0000 0139 unsigned char data;
; 0000 013A while (1)
	ST   -Y,R17
;	data -> R17
_0x6D:
; 0000 013B {
; 0000 013C if ((UCSR1A & 0x80) != 0)
	LDS  R30,200
	ANDI R30,LOW(0x80)
	BREQ _0x6D
; 0000 013D break;
; 0000 013E }
; 0000 013F data = UDR1;
	LDS  R17,206
; 0000 0140 UCSR1A |= 0x80;
	LDS  R30,200
	ORI  R30,0x80
	STS  200,R30
; 0000 0141 return data;
	MOV  R30,R17
_0x2000002:
	LD   R17,Y+
	RET
; 0000 0142 }
; .FEND
;interrupt[21] void timer1_ovf_isr(void)
; 0000 0145 {
_timer1_ovf_isr:
; .FSTART _timer1_ovf_isr
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R15
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R24
	ST   -Y,R25
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0146 int i;
; 0000 0147 
; 0000 0148 TCNT1H = 0xE1;
	ST   -Y,R17
	ST   -Y,R16
;	i -> R16,R17
	RCALL SUBOPT_0x6
; 0000 0149 TCNT1L = 0x7C;
; 0000 014A 
; 0000 014B for (i = 0; i < 17; i++)
	__GETWRN 16,17,0
_0x72:
	__CPWRN 16,17,17
	BRGE _0x73
; 0000 014C {
; 0000 014D buf[i] = Serial_Rece1();
	MOVW R30,R16
	SUBI R30,LOW(-_buf)
	SBCI R31,HIGH(-_buf)
	PUSH R31
	PUSH R30
	RCALL _Serial_Rece1
	POP  R26
	POP  R27
	ST   X,R30
; 0000 014E }
	__ADDWRN 16,17,1
	RJMP _0x72
_0x73:
; 0000 014F 
; 0000 0150 
; 0000 0151 }
	LD   R16,Y+
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R25,Y+
	LD   R24,Y+
	LD   R23,Y+
	LD   R22,Y+
	LD   R15,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
; .FEND
;void Set_Interrupt(void)
; 0000 0156 {
_Set_Interrupt:
; .FSTART _Set_Interrupt
; 0000 0157 TIMSK1 = 0x01;
	LDI  R30,LOW(1)
	STS  111,R30
; 0000 0158 
; 0000 0159 TCCR1A = 0;
	LDI  R30,LOW(0)
	STS  128,R30
; 0000 015A TCCR1B = 0x05;
	LDI  R30,LOW(5)
	STS  129,R30
; 0000 015B 
; 0000 015C TCNT1H = 0xE1; // 0.1s 마다 반복
	RCALL SUBOPT_0x6
; 0000 015D TCNT1L = 0x7C; // 0xffff(65535)+1-1562 = 63,974
; 0000 015E 
; 0000 015F TIFR1 = 0;
	LDI  R30,LOW(0)
	OUT  0x16,R30
; 0000 0160 #asm("sei");
	SEI
; 0000 0161 }
	RET
; .FEND
;void Ult_Sonic(void)
; 0000 0164 {
_Ult_Sonic:
; .FSTART _Ult_Sonic
; 0000 0165 int i;
; 0000 0166 
; 0000 0167 for (i = 8; i < 13; i++)
	ST   -Y,R17
	ST   -Y,R16
;	i -> R16,R17
	__GETWRN 16,17,8
_0x75:
	__CPWRN 16,17,13
	BRGE _0x76
; 0000 0168 {
; 0000 0169 if ((buf[i] < 0x15) && (0x09 < buf[i]) && (buf[i] != 0x00))
	RCALL SUBOPT_0x7
	LD   R26,X
	CPI  R26,LOW(0x15)
	BRSH _0x78
	RCALL SUBOPT_0x7
	LD   R30,X
	CPI  R30,LOW(0xA)
	BRLO _0x78
	RCALL SUBOPT_0x7
	LD   R26,X
	CPI  R26,LOW(0x0)
	BRNE _0x79
_0x78:
	RJMP _0x77
_0x79:
; 0000 016A {
; 0000 016B control = Emergency;
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	__PUTW1R 3,4
; 0000 016C break;
	RJMP _0x76
; 0000 016D }
; 0000 016E }
_0x77:
	__ADDWRN 16,17,1
	RJMP _0x75
_0x76:
; 0000 016F }
_0x2000001:
	LD   R16,Y+
	LD   R17,Y+
	RET
; .FEND
;void Stop_Setting(void)
; 0000 0172 {
_Stop_Setting:
; .FSTART _Stop_Setting
; 0000 0173 PORTH = 0x00;
	LDI  R30,LOW(0)
	STS  258,R30
; 0000 0174 DDRH = 0x40;  // 후방 LED
	LDI  R30,LOW(64)
	STS  257,R30
; 0000 0175 PORTH = 0x00; // 후방 LED OFF
	LDI  R30,LOW(0)
	STS  258,R30
; 0000 0176 DDRL = 0x10;  // 부저
	LDI  R30,LOW(16)
	STS  266,R30
; 0000 0177 PORTL = 0x00; // 부저 OFF
	LDI  R30,LOW(0)
	STS  267,R30
; 0000 0178 delay_ms(20);
	LDI  R26,LOW(20)
	LDI  R27,0
	RCALL _delay_ms
; 0000 0179 }
	RET
; .FEND
;void Emergency_Act(void)
; 0000 017C {
_Emergency_Act:
; .FSTART _Emergency_Act
; 0000 017D 
; 0000 017E Serial_Send0(control); // test
	MOV  R26,R3
	RCALL _Serial_Send0
; 0000 017F 
; 0000 0180 find_line = OutOfLine;
	CLR  R7
	CLR  R8
; 0000 0181 
; 0000 0182 Motor_dir(S);
	LDI  R26,LOW(4)
	LDI  R27,0
	RCALL _Motor_dir
; 0000 0183 Stop_Setting();
	RCALL _Stop_Setting
; 0000 0184 
; 0000 0185 RIGHT = 0;
	RCALL SUBOPT_0x8
; 0000 0186 LEFT = 0; // 전진
; 0000 0187 PORTH = PORTH | 0x40;
	RCALL SUBOPT_0x5
; 0000 0188 PORTL = PORTL | 0x10;
; 0000 0189 
; 0000 018A delay_ms(1000);
	LDI  R26,LOW(1000)
	LDI  R27,HIGH(1000)
	RCALL _delay_ms
; 0000 018B 
; 0000 018C PORTH = PORTH & (~0x40); // 후방 LED OFF
	LDS  R30,258
	ANDI R30,0xBF
	STS  258,R30
; 0000 018D PORTL = PORTL & (~0x10); // 부저 OFF
	LDS  R30,267
	ANDI R30,0xEF
	STS  267,R30
; 0000 018E 
; 0000 018F Motor_dir(T);
	LDI  R26,LOW(5)
	LDI  R27,0
	RCALL _Motor_dir
; 0000 0190 Initial_Motor_Setting();
	RCALL _Initial_Motor_Setting
; 0000 0191 
; 0000 0192 while (find_line != Found_Line)
_0x7A:
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CP   R30,R7
	CPC  R31,R8
	BREQ _0x7C
; 0000 0193 {
; 0000 0194 unsigned char IR = PINC;
; 0000 0195 
; 0000 0196 switch (find_line) // 1.라인벗어나기 2. 라인찾기
	SBIW R28,1
;	IR -> Y+0
	IN   R30,0x6
	ST   Y,R30
	__GETW1R 7,8
; 0000 0197 {
; 0000 0198 case OutOfLine:
	SBIW R30,0
	BRNE _0x80
; 0000 0199 if (IR == 0b11111111)
	LD   R26,Y
	CPI  R26,LOW(0xFF)
	BRNE _0x81
; 0000 019A find_line = Turn;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	__PUTW1R 7,8
; 0000 019B /*fall through*/
; 0000 019C case Turn:
_0x81:
	RJMP _0x82
_0x80:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x83
_0x82:
; 0000 019D RIGHT = Velocity_Detect;
	LDI  R30,LOW(140)
	OUT  0x28,R30
; 0000 019E LEFT = Velocity_Detect;
	STS  152,R30
; 0000 019F if (find_line == OutOfLine)
	MOV  R0,R7
	OR   R0,R8
	BREQ _0x7F
; 0000 01A0 break;
; 0000 01A1 /*fall through*/
; 0000 01A2 case GetInLine:
	RJMP _0x85
_0x83:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x88
_0x85:
; 0000 01A3 if (IR == 0b11100111)
	LD   R26,Y
	CPI  R26,LOW(0xE7)
	BRNE _0x87
; 0000 01A4 {
; 0000 01A5 find_line = Found_Line;
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	__PUTW1R 7,8
; 0000 01A6 RIGHT = 0;
	RCALL SUBOPT_0x8
; 0000 01A7 LEFT = 0;
; 0000 01A8 Motor_dir(S);
	LDI  R26,LOW(4)
	LDI  R27,0
	RCALL _Motor_dir
; 0000 01A9 }
; 0000 01AA break;
_0x87:
; 0000 01AB default:
_0x88:
; 0000 01AC break;
; 0000 01AD }
_0x7F:
; 0000 01AE }
	ADIW R28,1
	RJMP _0x7A
_0x7C:
; 0000 01AF }
	RET
; .FEND
;void main(void)
; 0000 01B2 {
_main:
; .FSTART _main
; 0000 01B3 
; 0000 01B4 int i;
; 0000 01B5 
; 0000 01B6 Stop_Setting();
;	i -> R16,R17
	RCALL _Stop_Setting
; 0000 01B7 
; 0000 01B8 Initial_Motor_Setting();
	RCALL _Initial_Motor_Setting
; 0000 01B9 Init_USART();
	RCALL _Init_USART
; 0000 01BA 
; 0000 01BB Set_Interrupt();
	RCALL _Set_Interrupt
; 0000 01BC 
; 0000 01BD // 전후방 기본 초음파 측정 요청
; 0000 01BE for (i = 0; i < 5; i++)
	__GETWRN 16,17,0
_0x8A:
	__CPWRN 16,17,5
	BRGE _0x8B
; 0000 01BF {
; 0000 01C0 Serial_Send1(Tx_buf1[i]);
	LDI  R26,LOW(_Tx_buf1)
	LDI  R27,HIGH(_Tx_buf1)
	ADD  R26,R16
	ADC  R27,R17
	LD   R26,X
	RCALL _Serial_Send1
; 0000 01C1 }
	__ADDWRN 16,17,1
	RJMP _0x8A
_0x8B:
; 0000 01C2 
; 0000 01C3 delay_ms(500);
	LDI  R26,LOW(500)
	LDI  R27,HIGH(500)
	RCALL _delay_ms
; 0000 01C4 
; 0000 01C5 while (control != THE_END)
_0x8C:
	LDI  R30,LOW(4444)
	LDI  R31,HIGH(4444)
	CP   R30,R3
	CPC  R31,R4
	BREQ _0x8E
; 0000 01C6 {
; 0000 01C7 Ult_Sonic();
	RCALL _Ult_Sonic
; 0000 01C8 Serial_Send0(control); // test
	MOV  R26,R3
	RCALL _Serial_Send0
; 0000 01C9 
; 0000 01CA switch (control)
	__GETW1R 3,4
; 0000 01CB {
; 0000 01CC case Emergency:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x92
; 0000 01CD Emergency_Act();
	RCALL _Emergency_Act
; 0000 01CE control = linetracing;
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	__PUTW1R 3,4
; 0000 01CF break;
	RJMP _0x91
; 0000 01D0 case linetracing:
_0x92:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x91
; 0000 01D1 Linetracer();
	RCALL _Linetracer
; 0000 01D2 break;
; 0000 01D3 }
_0x91:
; 0000 01D4 }
	RJMP _0x8C
_0x8E:
; 0000 01D5 delay_ms(3000);
	LDI  R26,LOW(3000)
	LDI  R27,HIGH(3000)
	RCALL _delay_ms
; 0000 01D6 PORTL = 0x00;
	LDI  R30,LOW(0)
	STS  267,R30
; 0000 01D7 PORTH = 0x00;
	STS  258,R30
; 0000 01D8 PORTB = 0x00;
	OUT  0x5,R30
; 0000 01D9 }
_0x94:
	RJMP _0x94
; .FEND

	.DSEG
_buf:
	.BYTE 0x11
_Tx_buf1:
	.BYTE 0x5
_Infrared_Sensor:
	.BYTE 0x28
_Compare_Value:
	.BYTE 0x10

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x0:
	LDS  R30,267
	ORI  R30,0x40
	STS  267,R30
	__DELAY_USB 5
	LDS  R30,267
	ANDI R30,0xBF
	STS  267,R30
	__DELAY_USB 5
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x1:
	LDS  R30,267
	ORI  R30,0x20
	STS  267,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x2:
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X+
	LD   R31,X+
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x3:
	LDI  R27,0
	RCALL _Motor_dir
	LDI  R30,LOW(170)
	OUT  0x28,R30
	STS  152,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x4:
	LDI  R27,0
	RCALL _Motor_dir
	LDI  R30,LOW(220)
	OUT  0x28,R30
	STS  152,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x5:
	LDS  R30,258
	ORI  R30,0x40
	STS  258,R30
	LDS  R30,267
	ORI  R30,0x10
	STS  267,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x6:
	LDI  R30,LOW(225)
	STS  133,R30
	LDI  R30,LOW(124)
	STS  132,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x7:
	LDI  R26,LOW(_buf)
	LDI  R27,HIGH(_buf)
	ADD  R26,R16
	ADC  R27,R17
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x8:
	LDI  R30,LOW(0)
	OUT  0x28,R30
	STS  152,R30
	RET

;RUNTIME LIBRARY

	.CSEG
__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__LSLW12:
	TST  R30
	MOV  R0,R30
	LDI  R30,8
	MOV  R1,R30
	MOVW R30,R26
	BREQ __LSLW12R
__LSLW12S8:
	CP   R0,R1
	BRLO __LSLW12L
	MOV  R31,R30
	LDI  R30,0
	SUB  R0,R1
	BREQ __LSLW12R
__LSLW12L:
	LSL  R30
	ROL  R31
	DEC  R0
	BRNE __LSLW12L
__LSLW12R:
	RET

__LSRW12:
	TST  R30
	MOV  R0,R30
	LDI  R30,8
	MOV  R1,R30
	MOVW R30,R26
	BREQ __LSRW12R
__LSRW12S8:
	CP   R0,R1
	BRLO __LSRW12L
	MOV  R30,R31
	LDI  R31,0
	SUB  R0,R1
	BREQ __LSRW12R
__LSRW12L:
	LSR  R31
	ROR  R30
	DEC  R0
	BRNE __LSRW12L
__LSRW12R:
	RET

__LSLW4:
	LSL  R30
	ROL  R31
__LSLW3:
	LSL  R30
	ROL  R31
__LSLW2:
	LSL  R30
	ROL  R31
	LSL  R30
	ROL  R31
	RET

_delay_ms:
	adiw r26,0
	breq __delay_ms1
__delay_ms0:
	wdr
	__DELAY_USW 0xFA0
	sbiw r26,1
	brne __delay_ms0
__delay_ms1:
	ret

;END OF CODE MARKER
__END_OF_CODE:
