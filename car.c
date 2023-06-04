#include <mega2560.h>
#include <delay.h>

//Port
#define LEFT_MD_A PORTA .0
#define LEFT_MD_B PORTA .1
#define L_MOTOR_EN PORTG .5
#define RIGHT_MD_A PORTA .2
#define RIGHT_MD_B PORTA .3
#define R_MOTOR_EN PORTE .3

#define clear 0
#define LEFT OCR3AL
#define RIGHT OCR0B

//switch
#define F 1
#define L 2
#define R 3
#define S 4
#define linetracing 1
#define emergency 2

//velocity
#define Velocity_Forward 28 //전진속도
#define Velocity_Low 130    // Low Turn
#define Velocity_High 220   // High turn
#define Velocity_Detect 100 // 라인을 찾기위한 회전속도

void DAC_CH_Write(unsigned int, unsigned int);
void DAC_setting(unsigned int);

void Initial_Motor_Setting(void);
void Initial_Sensor_Setting(void);
int Decoding_Sensor(unsigned char buf[17]);

void Motor_Control(unsigned int IR);
void Motor_dir(int c);
void linetracer(void);
void Emergency_Act(void);

void Initial_Sensor_Setting(void);
void Serial_Send0(unsigned char);
void Serial_Send1(unsigned char);
void Sensor(void);

unsigned char buf[17]; // 전체 초음파 측정 데이터를 Tx_buf1[5] 에 배열로 저장
unsigned char Tx_buf1[5] = { 0x76, 0x00, 0xF0, 0x00, 0xF0 };
unsigned char ch[7];



unsigned int Compare_Value[8] = {72, 75, 81, 77, 66, 65, 78, 75}; //n번 센서, (black+(white-black)/2)/4 

int control;

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
    unsigned char IR = 0;

    DDRA = DDRA|0x1f; // 적외선 발광다이오드 구동 및  모터드라이버
    DDRC = 0x00; // Digtial Input
    DDRL = 0xe0; // serial

    PORTL = PORTL & 0xbf; // s_clk = 0
    PORTL = PORTL | 0x20; // sycn' = 1

    PORTA = PORTA|0x10; // 적외선 발광다이오드 ON
    DDRG = DDRG|0x20;  // 왼쪽모터 Enable단자 출력으로 초기화
    DDRE = DDRE|0x08;  // PE3 PWM신호로 설정

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
    LEFT = clear; // 오른쪽바퀴 Low bit clear

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

void linetracer(void)
{

    int i;
    unsigned char IR = 0;
    Initial_Motor_Setting();


        IR = PINC;

        delay_ms(5);

        if (IR == 0b11110111 || IR == 0b11101111 || IR == 0b11100111 || IR == 0b11001111 || IR == 0b11110011 || IR == 0b11000111 || IR == 0b11100011)

        {
            Motor_dir(F);
            RIGHT = Velocity_Forward;
            LEFT = Velocity_Forward; // 전진
        }

        else if (IR == 0b11111101 || IR == 0b11111011 || IR == 0b11111001 || IR == 0b11110001)

        {

            Motor_dir(L);

            RIGHT = 0;
            LEFT = Velocity_Low; // 좌
        }

        else if (IR == 0b11111110 || IR == 0b11111100)

        {

            Motor_dir(L);

            RIGHT = 0;
            LEFT = Velocity_High;
        }

        else if (IR == 0b10111111 || IR == 0b11011111 || IR == 0b10011111 || IR == 0b10001111)

        {

            Motor_dir(R);

            RIGHT = Velocity_Low;
            LEFT = 0;
        }

        else if (IR == 0b01111111 || IR == 0b00111111)

        {
            Motor_dir(R);

            RIGHT = Velocity_High;
            LEFT = 0;
        }
   
}
void Initial_Sensor_Setting(void){      // Init_USART

// 시리얼 포트 0는 블루투스와의 통신 포트이다
    DDRE = 0xfe;
    UCSR0A = 0x00;
    UCSR0B = 0x18; //TXE, RXE Enable
    UCSR0C = 0x06; // 비동기, Non Parity, 1 Stop Bit
    UBRR0H = 0x00;
    UBRR0L = 0x08; //115200bps    
    
// 시리얼 포트 1은 초음파 센서 모듈과의 통신 포트이다
    DDRD = 0x08; 
    UCSR1A = 0x00; 
    UCSR1B = 0x18; // TXE, RXE Enable 
    UCSR1C = 0x06; // 비동기, Non Parity, 1 Stop Bit
    UBRR1H = 0x00;
    UBRR1L = 0x08; //115200 bps 
    DDRB = 0xff; 
}

// 시리얼 포트 0에 1 Byte 씩 전송하는 함수이다. 
void Serial_Send0(unsigned char t)
{ 
    // 전송 준비가 될 때 까지 대기 
    while(1) { 
        if((UCSR0A & 0x20) !=0 ) break;
}

    UDR0 = t ;
    UCSR0A = UCSR0A | 0x20 ;
} 

// 시리얼 포트 1에 1 Byte 씩 전송하는 함수이다. 
void Serial_Send1(unsigned char t)
{ 
     // 전송준비가 될 때 까지 대기
    while(1) {
        if( (UCSR1A & 0x20 ) !=0 ) break; 
    }
        
    UDR1 = t ;
    UCSR1A = UCSR1A | 0x20 ;
} 

// 시리얼 포트 1에서 데이터를 수신하는 함수이다. 
unsigned char Serial_Rece1(void)
{ 
    unsigned char data ; 
    
    while(1) {
        if((UCSR1A & 0x80 ) !=0 ) break;
        }
        data = UDR1;
        UCSR1A |=0x80 ;
        return data;
} 

 
// 시리얼 포트 0에 문장을 송신하는 함수이다. 
void SerialData0( char *str )
{
    while(*str) Serial_Send0(*str++);
} 
    
void Sensor(void){

    int i = 0; 
    
    Initial_Sensor_Setting( ); // 시리얼 포트 0, 1 초기와 
 
    for( i = 0 ;i < 5 ;i++){ 
        Serial_Send1(Tx_buf1[i]); // 전체 초음파 측정 데이터를 요청 
    }    
        
    // 초음파 모듈에서 17바이트의 데이터를 받는다 . 
    for( i = 0 ; i < 17 ; i ++ ){
        buf[i] = Serial_Rece1( ); 
    } 
}
int Decoding_Sensor(unsigned char buf[17])
{
		int i=0;
		int compare = 0;
		for (i=4;i<9;i++){
			compare = i;
		if(buf[i]<0x46) (control = emergency; break;)
	}
    return compare;
}
void Emergency_Act()    //장애물 발견
{
	Motor_dir(S);

    RIGHT = 0;
    LEFT = 0; // 전진
	PORTH = PORTH|0x40;
	PORTL = PORTL|0x10;

    delay_ms(1000);
    Motor_dir(R);

    while(1){
	    unsigned char IR = PINC;

        RIGHT = Velocity_Detect;
        LEFT = 0;
        control = linetracing;

        if (IR != 11111111) break;    
     
    }
}

interrupt[TIM1_OVF] void timer1_ovf_isr(void)
{
    TCNT1H = 0xF9;
    TCNT1L = 0xE6;

    Sensor();   // Interrupt에서 불러와서 괜찮을까 함수가 너무 큰게 아닐까?

}

void main(void)
{
    TIMSK1 = 0x01;

    TCCR1A = 0;
    TCCR1B = 0x05;
                                
    TCNT1H =  0xF9;            // 0.1s 마다 반복
    TCNT1L = 0xE6;             //0xffff(65535)+1-1562 = 63,974

    T1FR1 = 0;
    
    #asm("sei");

    while (1)
    {
		control=Decoding_Sensor();

		switch(control){
	        case linetracing: linetracer();break;
		    case emergency: Emergency_Act(); break;
		}
    }
}