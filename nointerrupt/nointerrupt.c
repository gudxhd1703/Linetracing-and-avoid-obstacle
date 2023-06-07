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
#define T 5
#define linetracing 1
#define Emergency 2

// velocity
#define Velocity_Forward 40 // �����ӵ�
#define Velocity_Low 170    // Low Turn
#define Velocity_High 220   // High turn
#define Velocity_Detect 140 // ������ ã������ ȸ���ӵ�
#define OutOfLine 0
#define Turn 1
#define GetInLine 2
#define Found_Line 3
#define THE_END 4444

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
void Ult_Sonic(void);

unsigned char buf[17]; // ��ü ������ ���� �����͸� Tx_buf1[5] �� �迭�� ����
unsigned char Tx_buf1[5] = {0x76, 0x00, 0xF0, 0x00, 0xF0};
unsigned int Infrared_Sensor[20] = {
    0b11110111, 0b11101111, 0b11100111, 0b11001111, 0b11110011, 0b11000111, 0b11100011, // ����
    0b11111101, 0b11111011, 0b11111001, 0b11110001, 0b11111110, 0b11111100,             // ��ȸ��
    0b10111111, 0b11011111, 0b10011111, 0b10001111, 0b01111111, 0b00111111,             // ��ȸ��
    0b00000000                                                                          // THE_END
};
unsigned int Compare_Value[8] = {88, 108, 103, 86, 85, 74, 81, 73}; // n�� ����, (black+(white-black)/2)/4

unsigned int control = linetracing;
int check_flag = 0;
unsigned int find_line;

// DA ��ȯ�� ����� �������� �ش� �����͸� ���� �Լ�
void DAC_CH_Write(unsigned int ch1, unsigned int da)
{
    unsigned int data = ((ch1 << 12) & 0x7000) | ((da << 4) & 0x0ff0);
    DAC_setting(data);
}

void DAC_setting(unsigned int data)
{
    unsigned char S_DIN = clear; // PL7 �ʱ�ȭ
    int i = 0;

    PORTL = PORTL | 0x40; // S_CLK = 0
    delay_us(1);

    PORTL = PORTL & 0xbf; // S_CLK = 1   falling_edge
    delay_us(1);

    PORTL = PORTL & 0xdf; // sycn' = 1
    delay_us(1);

    for (i = 16; i > 0; i--)
    {
        S_DIN = (data >> (i - 1)) & 0x01; // MSB���� LSB�� �̵��ø� �����͸� S_DIN�� �����Ͽ� Ȯ���Ѵ�.

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

    DDRA = DDRA | 0x1f; // ���ܼ� �߱����̿��� ���� ��  ���͵���̹�
    DDRC = 0x00;        // Digtial Input
    DDRL = 0xe0;        // serial

    PORTL = PORTL & 0xbf; // s_clk = 0
    PORTL = PORTL | 0x20; // sycn' = 1

    PORTA = PORTA | 0x10; // ���ܼ� �߱����̿��� ON
    DDRG = DDRG | 0x20;   // ���ʸ��� Enable���� ������� �ʱ�ȭ
    DDRE = DDRE | 0x08;   // PE3 PWM��ȣ�� ����

    PORTG = clear;
    PORTE = clear;

    TCCR0A = 0x21; // PWM Phase correct mode�� ���, compare match���
    TCCR0B = 0x05; // ��ī��Ʈ�� TCNTO�� OCR0�� ��ġ�ϸ� OCR0 clear ����ī��Ʈ�ÿ� ��ġ�ϸ� SET
    TCNT0 = clear;

    RIGHT = clear; // ���ʹ��� pwm�ð� �Է�

    TCCR3A = 0x81; // 8��Ʈ ����� phase corrct pwm ���� ����
    TCCR3B = 0x05; // compare match ����ī���� OC3A�� Ŭ���� ����ī���Ϳ��� set

    TCNT3L = clear;
    TCNT3H = clear;

    OCR3AH = clear; // �����ʹ��� High bit clear
    LEFT = clear;   // �����ʹ��� Low bit clear

    DAC_setting(0x9000);

    for (i = 0; i < 8; i++)
    {
        DAC_CH_Write(i, Compare_Value[i]);
    }

    delay_ms(20);
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
        LEFT_MD_B = 1;
        L_MOTOR_EN = 1;
        RIGHT_MD_A = 0;
        RIGHT_MD_B = 1;
        R_MOTOR_EN = 1;
        break;
    case R:
        LEFT_MD_A = 1;
        LEFT_MD_B = 0;
        L_MOTOR_EN = 1;
        RIGHT_MD_A = 1;
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
    case T:
        LEFT_MD_A = 1;
        LEFT_MD_B = 0;
        L_MOTOR_EN = 1;
        RIGHT_MD_A = 1;
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

    delay_ms(5);

    for (i = 0; i < 20; i++)
    {
        if (IR == Infrared_Sensor[i])
        {
            data = i;
            break;
        }
    }

    Motor_dir(S);   //�������� ����

    if (data < 7)
    {
        Motor_dir(F);
        RIGHT = Velocity_Forward;
        LEFT = Velocity_Forward;
    }
    else if (data < 11)
    {
        Motor_dir(L);
        RIGHT = Velocity_Low;
        LEFT = Velocity_Low;
    }
    else if (data < 13)
    {
        Motor_dir(L);
        RIGHT = Velocity_High;
        LEFT = Velocity_High;
    }
    else if (data < 17)
    {
        Motor_dir(R);
        RIGHT = Velocity_Low;
        LEFT = Velocity_Low;
    }
    else if (data < 19)
    {
        Motor_dir(R);
        RIGHT = Velocity_High;
        LEFT = Velocity_High;
    }
    else if (data == 19)
    {
        Stop_Setting();
        PORTH = PORTH | 0x40;
        PORTL = PORTL | 0x10;
        PORTB = PORTB | 0x10;
        control = THE_END;
    }
}
void Init_USART(void)
{ // Init_USART

    // �ø��� ��Ʈ 0�� ����������� ��� ��Ʈ�̴�
    DDRE = 0xfe;
    UCSR0A = 0x00;
    UCSR0B = 0x18; // TXE, RXE Enable
    UCSR0C = 0x06; // �񵿱�, Non Parity, 1 Stop Bit
    UBRR0H = 0x00;
    UBRR0L = 0x08; // 115200bps

    // �ø��� ��Ʈ 1�� ������ ���� ������ ��� ��Ʈ�̴�
    DDRD = 0x08;
    UCSR1A = 0x00;
    UCSR1B = 0x18; // TXE, RXE Enable
    UCSR1C = 0x06; // �񵿱�, Non Parity, 1 Stop Bit
    UBRR1H = 0x00;
    UBRR1L = 0x08; // 115200 bps
    DDRB = 0xff;
}

// �ø��� ��Ʈ 0�� 1 Byte �� �����ϴ� �Լ��̴�.
void Serial_Send0(unsigned char t)
{
    // ���� �غ� �� �� ���� ���
    while (1)
    {
        if ((UCSR0A & 0x20) != 0)
            break;
    }

    UDR0 = t;
    UCSR0A = UCSR0A | 0x20;
}

// �ø��� ��Ʈ 0�� ������ �۽��ϴ� �Լ��̴�.
void SerialData0(char *str)
{
    while (*str)
        Serial_Send0(*str++);
}
// �ø��� ��Ʈ 1�� 1 Byte �� �����ϴ� �Լ��̴�.
void Serial_Send1(unsigned char t)
{
    // �����غ� �� �� ���� ���
    while (1)
    {
        if ((UCSR1A & 0x20) != 0)
            break;
    }
    UDR1 = t;
    UCSR1A = UCSR1A | 0x20;
}
// �ø��� ��Ʈ 1���� �����͸� �����ϴ� �Լ��̴�.
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

interrupt[TIM1_OVF] void timer1_ovf_isr(void) // 0.1s���� ������ �����ϰ� flag�� ������
{
    int i;

    TCNT1H = 0xE1;
    TCNT1L = 0x7C;

    for (i = 0; i < 17; i++)
    {
        buf[i] = Serial_Rece1();
    }


}

// 16������ ASCII ���ڷ� ��ȯ�� �ִ� �Լ��̴�.

void Set_Interrupt(void)
{
    TIMSK1 = 0x01;

    TCCR1A = 0;
    TCCR1B = 0x05;

    TCNT1H = 0xE1; // 0.1s ���� �ݺ�
    TCNT1L = 0x7C; // 0xffff(65535)+1-1562 = 63,974

    TIFR1 = 0;
#asm("sei");
}

void Ult_Sonic(void)
{
    int i;

    for (i = 8; i < 13; i++)
    {
        if ((buf[i] < 0x15) && (0x09 < buf[i]) && (buf[i] != 0x00))
        {
            control = Emergency;
            break;
        }
    }
}

void Stop_Setting(void)
{
    PORTH = 0x00;
    DDRH = 0x40;  // �Ĺ� LED
    PORTH = 0x00; // �Ĺ� LED OFF
    DDRL = 0x10;  // ����
    PORTL = 0x00; // ���� OFF
    delay_ms(20);
}

void Emergency_Act(void) // �����ķ� ��ֹ� ������
{

    Serial_Send0(control); // test

    find_line = OutOfLine;

    Motor_dir(S);
    Stop_Setting();

    RIGHT = 0;
    LEFT = 0; // ����
    PORTH = PORTH | 0x40;
    PORTL = PORTL | 0x10;

    delay_ms(1000);

    PORTH = PORTH & (~0x40); // �Ĺ� LED OFF
    PORTL = PORTL & (~0x10); // ���� OFF

    Motor_dir(T);
    Initial_Motor_Setting();

    while (find_line != Found_Line)
    {
        unsigned char IR = PINC;

        switch (find_line) // 1.���ι���� 2. ����ã��
        {
        case OutOfLine:
            if (IR == 0b11111111)
                find_line = Turn;
            /*fall through*/
        case Turn:
            RIGHT = Velocity_Detect;
            LEFT = Velocity_Detect;
            if (find_line == OutOfLine)
                break;
            /*fall through*/
        case GetInLine:
            if (IR == 0b11100111)
            {
                find_line = Found_Line;
                RIGHT = 0;
                LEFT = 0;
                Motor_dir(S);
            }
            break;
        default:
            break;
        }
    }
}

void main(void)
{

    int i;

    Stop_Setting();

    Initial_Motor_Setting();
    Init_USART();

    Set_Interrupt();

    // ���Ĺ� �⺻ ������ ���� ��û
    for (i = 0; i < 5; i++)
    {
        Serial_Send1(Tx_buf1[i]);
    }

    delay_ms(500);

    while (control != THE_END)
    {
        Ult_Sonic();
        Serial_Send0(control); // test

        switch (control)
        {
        case Emergency:
            Emergency_Act();
            control = linetracing;
            break;
        case linetracing:
            Linetracer();
            break;
        }
    }
    delay_ms(3000);
    PORTL = 0x00;
    PORTH = 0x00;
    PORTB = 0x00;
}