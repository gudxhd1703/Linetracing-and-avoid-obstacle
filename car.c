#include <mega2560.h>
#include <delay.h>

// Port
#define LEFT_MD_A PORTA .0
#define LEFT_MD_B PORTA .1
#define L_MOTOR_EN PORTG .5
#define RIGHT_MD_A PORTA .2
#define RIGHT_MD_B PORTA .3
#define R_MOTOR_EN PORTE .3

#define clear 0
#define LEFT OCR3AL
#define RIGHT OCR0B

// switch
#define F 1
#define L 2
#define R 3
#define S 4
#define linetracing 1
#define Emergency 2

// velocity
#define Velocity_Forward 28 // 전진속도
#define Velocity_Low 130    // Low Turn
#define Velocity_High 220   // High turn
#define Velocity_Detect 100 // 라인을 찾기위한 회전속도

void DAC_CH_Write(unsigned int, unsigned int);
void DAC_setting(unsigned int);

void Initial_Motor_Setting(void);
void Init_USART(void);
void Stop_Setting(void);

void Motor_dir(int c);
void Linetracer(void);
void Emergency_Act(void);

void Serial_Send0(unsigned char);
void SerialData0(char *str);
unsigned char Serial_Rece1(void);
void HtoA(int s);
void Ult_Sonic(void);
void Decoding_Sensor(void);

unsigned char buf[17]; // 전체 초음파 측정 데이터를 Tx_buf1[5] 에 배열로 저장
unsigned char Tx_buf1[5] = {0x76, 0x00, 0xF0, 0x00, 0xF0};
unsigned char ch[7];

unsigned int Infrared_Sensor[19] = {
    0b11110111, 0b11101111, 0b11100111, 0b11001111, 0b11110011, 0b11000111, 0b11100011, // 직진
    0b11111101, 0b11111011, 0b11111001, 0b11110001, 0b11111110, 0b11111100,             // 우회전
    0b10111111, 0b11011111, 0b10011111, 0b10001111, 0b01111111, 0b00111111              // 좌회전
};
unsigned int Compare_Value[8] = {72, 75, 81, 77, 66, 65, 78, 75}; // n번 센서, (black+(white-black)/2)/4

int control = linetracing;
int check_flag = 0;

// DA 변환기 출력을 내기위해 해당 데이터를 쓰는 함수
void DAC_CH_Write(unsigned int ch1, unsigned int da)
{
    unsigned int data = ((ch1 << 12) & 0x7000) | ((da << 4) & 0x0ff0);
    DAC_setting(data);
}

void DAC_setting(unsigned int data)
{
    unsigned char S_DIN = clear; // PL7 초기화
    int i = 0;

    PORTL = PORTL | 0x40; // S_CLK = 0
    delay_us(1);

    PORTL = PORTL & 0xbf; // S_CLK = 1   falling_edge
    delay_us(1);

    PORTL = PORTL & 0xdf; // sycn' = 1
    delay_us(1);

    for (i = 16; i > 0; i--)
    {
        S_DIN = (data >> (i - 1)) & 0x01; // MSB에서 LSB로 이동시며 데이터를 S_DIN에 저장하여 확인한다.

        if (S_DIN == 1)
            PORTL = PORTL | 0x80;
        else if (S_DIN == 0)
            PORTL = PORTL & 0x7f;

        PORTL = PORTL | 0x40; // S_CLK = 1
        delay_us(1);

        PORTL = PORTL & 0xbf; // S_CLK = 0
        delay_us(1);
    }
    PORTL = PORTL | 0x20; // sync' = 1
}

void Initial_Motor_Setting(void)
{

    int i = 0;

    DDRA = DDRA | 0x1f; // 적외선 발광다이오드 구동 및  모터드라이버
    DDRC = 0x00;        // Digtial Input
    DDRL = 0xe0;        // serial

    PORTL = PORTL & 0xbf; // s_clk = 0
    PORTL = PORTL | 0x20; // sycn' = 1

    PORTA = PORTA | 0x10; // 적외선 발광다이오드 ON
    DDRG = DDRG | 0x20;   // 왼쪽모터 Enable단자 출력으로 초기화
    DDRE = DDRE | 0x08;   // PE3 PWM신호로 설정

    PORTG = clear;
    PORTE = clear;

    TCCR0A = 0x21; // PWM Phase correct mode로 사용, compare match모드
    TCCR0B = 0x05; // 업카운트시 TCNTO와 OCR0가 일치하면 OCR0 clear 하향카운트시에 일치하면 SET
    TCNT0 = clear;

    RIGHT = clear; // 왼쪽바퀴 pwm시간 입력

    TCCR3A = 0x81; // 8비트 모드의 phase corrct pwm 모드로 동작
    TCCR3B = 0x05; // compare match 상향카운터 OC3A를 클리어 하향카운터에서 set

    TCNT3L = clear;
    TCNT3H = clear;

    OCR3AH = clear; // 오른쪽바퀴 High bit clear
    LEFT = clear;   // 오른쪽바퀴 Low bit clear

    DAC_setting(0x9000);

    for (i = 0; i < 8; i++)
    {
        DAC_CH_Write(i, Compare_Value[i]);
    }
}

void Motor_dir(int c)
{

    switch (c)
    { // F = Forward , L = Left, R = Right
    case F:
        LEFT_MD_A = 1;
        LEFT_MD_B = 0;
        L_MOTOR_EN = 1;
        RIGHT_MD_A = 0;
        RIGHT_MD_B = 1;
        R_MOTOR_EN = 1;
        break;
    case L:
        LEFT_MD_A = 0;
        LEFT_MD_B = 0;
        L_MOTOR_EN = 1;
        RIGHT_MD_A = 0;
        RIGHT_MD_B = 1;
        R_MOTOR_EN = 1;
        break;
    case R:
        LEFT_MD_A = 1;
        LEFT_MD_B = 0;
        L_MOTOR_EN = 1;
        RIGHT_MD_A = 0;
        RIGHT_MD_B = 0;
        R_MOTOR_EN = 1;
        break;
    case S:
        LEFT_MD_A = 0;
        LEFT_MD_B = 0;
        L_MOTOR_EN = 1;
        RIGHT_MD_A = 0;
        RIGHT_MD_B = 0;
        R_MOTOR_EN = 1;
        break;
    }
}

void Linetracer(void)
{

    int i, data = 0;
    unsigned char IR = 0;

    IR = PINC;

    // delay_ms(5);

    for (i = 0; i < 19; i++)
    {
        if (IR == Infrared_Sensor[i])
        {
            data = i;
            break;
        }
    }
    if (data < 7)
    {
        Motor_dir(F);
        RIGHT = Velocity_Forward;
        LEFT = Velocity_Forward;
    }
    else if (data < 11)
    {
        Motor_dir(L);
        RIGHT = 0;
        LEFT = Velocity_Low;
    }
    else if (data < 13)
    {
        Motor_dir(L);
        RIGHT = 0;
        LEFT = Velocity_High;
    }
    else if (data < 17)
    {
        Motor_dir(R);
        RIGHT = Velocity_Low;
        LEFT = 0;
    }
    else
    {
        Motor_dir(R);
        RIGHT = Velocity_High;
        LEFT = 0;
    }
}
void Init_USART(void)
{ // Init_USART

    // 시리얼 포트 0는 블루투스와의 통신 포트이다
    DDRE = 0xfe;
    UCSR0A = 0x00;
    UCSR0B = 0x18; // TXE, RXE Enable
    UCSR0C = 0x06; // 비동기, Non Parity, 1 Stop Bit
    UBRR0H = 0x00;
    UBRR0L = 0x08; // 115200bps

    // 시리얼 포트 1은 초음파 센서 모듈과의 통신 포트이다
    DDRD = 0x08;
    UCSR1A = 0x00;
    UCSR1B = 0x18; // TXE, RXE Enable
    UCSR1C = 0x06; // 비동기, Non Parity, 1 Stop Bit
    UBRR1H = 0x00;
    UBRR1L = 0x08; // 115200 bps
    DDRB = 0xff;
}

// 시리얼 포트 0에 1 Byte 씩 전송하는 함수이다.
void Serial_Send0(unsigned char t)
{
    // 전송 준비가 될 때 까지 대기
    while (1)
    {
        if ((UCSR0A & 0x20) != 0)
            break;
    }

    UDR0 = t;
    UCSR0A = UCSR0A | 0x20;
}

// 시리얼 포트 0에 문장을 송신하는 함수이다.
void SerialData0(char *str)
{
    while (*str)
        Serial_Send0(*str++);
}
// 시리얼 포트 1에 1 Byte 씩 전송하는 함수이다.
void Serial_Send1(unsigned char t)
{
    // 전송준비가 될 때 까지 대기
    while (1)
    {
        if ((UCSR1A & 0x20) != 0)
            break;
    }
    UDR1 = t;
    UCSR1A = UCSR1A | 0x20;
}
// 시리얼 포트 1에서 데이터를 수신하는 함수이다.
unsigned char Serial_Rece1(void)
{
    unsigned char data;
    while (1)
    {
        if ((UCSR1A & 0x80) != 0)
            break;
    }
    data = UDR1;
    UCSR1A |= 0x80;
    return data;
}

interrupt[TIM1_OVF] void timer1_ovf_isr(void)
{
    TCNT1H = 0xE1;
    TCNT1L = 0x7C;

    switch (check_flag)
    {
    case 0:
        check_flag = 1;
        break;
    case 1:
        check_flag = 0;
        break;
    }
}

// 16진수를 ASCII 문자로 변환해 주는 함수이다.

void HtoA(int s)
{
    int buff;
    ch[0] = s / 0x1000;
    buff = s % 0x1000;
    if (ch[0] < 10)
        ch[0] = ch[0] + 0x30;
    else
        ch[0] = ch[0] + 55;
    ch[1] = buff / 0x100;
    buff = buff % 0x100;
    if (ch[1] < 10)
        ch[1] = ch[1] + 0x30;
    else
        ch[1] = ch[1] + 55;
    ch[2] = buff / 0x10;
    buff = buff % 0x10;
    if (ch[2] < 10)
        ch[2] = ch[2] + 0x30;
    else
        ch[2] = ch[2] + 55;
    ch[3] = buff;
    if (ch[3] < 10)
        ch[3] = ch[3] + 0x30;
    else
        ch[3] = ch[3] + 55;
    ch[4] = ' '; // 스페이스를 넣는다
    ch[5] = 0;
}

void Set_Interrupt(void)
{
    TIMSK1 = 0x01;

    TCCR1A = 0;
    TCCR1B = 0x05;

    TCNT1H = 0xE1; // s 마다 반복
    TCNT1L = 0x7C; // 0xffff(65535)+1-1562 = 63,974

    TIFR1 = 0; 
    #asm("sei");
}

void Ult_Sonic(void){
    int i;

if (check_flag == 1)
        {
            for (i = 0; i < 17; i++)
            {
                buf[i] = Serial_Rece1();
            }
            // 받은 17바이트의 데이터를 블루투스로 스마트폰에 송신한다.
            for (i = 0; i < 17; i++)
            {
                HtoA(buf[i]);
                SerialData0(ch);
            }
            Serial_Send0(0x0d);
            Serial_Send0(0x0a);
        }
}

void Stop_Setting(void)
{
        DDRH = 0x40;  // 후방 LED
        PORTH = 0x00; // 후방 LED OFF
        DDRL = 0x10;  // 부저
        PORTL = 0x00; // 부저 OFF
}

void Emergency_Act(void){

    Motor_dir(S);

    RIGHT = 0;
    LEFT = 0; // 전진
	PORTH = PORTH|0x40;
	PORTL = PORTL|0x10;

    delay_ms(1000);

    PORTH = PORTH&(~0x40); // 후방 LED OFF
    PORTL = PORTL&(~0x10) ; // 부저 OFF

    control = linetracing;


}

void Decoding_Sensor(){

    int i;

		for (i=4;i<9;i++){
        if (0x09<buf[i] < 0x26)
        {
            Serial_Send0(buf[i]);
            // control = Emergency;
            break;
        }
    }
}

void main(void)
{

    int i;

    Initial_Motor_Setting();
    Init_USART();

    Set_Interrupt();

    Stop_Setting();
    

    // 전후방 기본 초음파 측정 요청
    for (i = 0; i < 5; i++)
    {
        Serial_Send1(Tx_buf1[i]);
    }

    while (1)
    {
        Ult_Sonic();
        Decoding_Sensor();

        switch (control)
        {
        case Emergency: Emergency_Act();break;
        case linetracing:
            Linetracer();
            break;
        }
    }
}