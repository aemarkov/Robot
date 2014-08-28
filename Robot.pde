//============================= Подключения =====================
#include <Servo.h>
//============================= Объявления объектов =============
Servo LRServo;
Servo LServo;
Servo RServo;
//============================= Константы =======================
//----------------------------- Константы датчиков -------------
#define Array_Size 90 //Размер массива сканирования
#define ScanDelay 10  //Задержка сканирования
#define Min_Val 70    //Пороговое значение обнаружения препятсвия
//----------------------------- Константы навигации ------------
#define Rot_Scale 12 //милисекунд на градус
#define Stop_Time 93 //Значения, при котором сервы не двигаються
#define Scale 500 //ms for point
#define minL 2 //На сколько надо проехать чтобы снова выполнить программу
//----------------------------- Константы выводов --------------
//#define upPin 57
//#define downPin 56
#define leftPin 55
#define rightPin 54

#define LedPin 6

int LEDS[4]={2,3,4,5};
int DAT[4]={56,57,58,59};
//-------------------------------------------------------------
//============================= Глобальные переменные =========
float AngleScale=0; //градусов на 1 шаг
//--------------------------
byte Pos=90; //Позиция сервы
//---------------------------
/*int upPin=57;
int downPin=56;
int leftPin = 55;
int rightPin = 54;
int LedPin = 6;*/
long int time=0;
//-------------------Значения с "головы" -------------------
int upVal=0;
int downVal=0;
int leftVal=0;
int rightVal =0;
//------------------ Значения с датчиков падения ----------
int Pad[4]={0,0,0,0};

// Значение для управления функцией Scan
struct ScanDataType{
	byte Mode;
	int i;
        long int Time;
        boolean on;
};

static ScanDataType ScanData = {1,0,0,false};
/* Mode 0 - rotate from 0 to 180
Mode 1 - rotate from 180 to 0
Mode 2 - compleate
*/
//--------------------------
int Data [2][Array_Size]; //Массив данных с "головы"
//------------ Навигация -----------------
//============================ Координаты контрольных точек
byte pCoor[2][100];
byte pNo=0;

byte X=128; //Текущие координаты
byte Y=128; //
byte Xt=255;//координаты следующей контрольной точки
byte Yt = 255; 
int Angle =90; //Текущий угол
int Bearing = 0; //Угол на точку
byte Coords[2][100]; //Массив с координатами точек
byte No=0; //Кол-во точек

byte L =100; //Расстояние, пройденное с момента последнего измерения
//-----------------------
long int Nav_Time=0; //Время движения
//================================= Прочие системные переменные ====================
byte isObst=0; //Есть ли препятсвие
/* 0 - нет, 1-спереди, 2-яма спереди, 3-яма сзади*/

//**********************************************************************
//----------------------------------------------------------------------
//**********************************************************************
void setup(){
//Serial.begin (9600);
LRServo.attach(9);
RServo.attach (10);
LServo.attach (11);
time = millis()+3000;
AngleScale = 180/Array_Size;

//for (int _i=0; _i<=99;_i++){Coords[0][_i]=0; Coords[1][_i]=0;}
}

void loop(){
Detect();
if (isObst==1){ScanData.on=true; Scan();}
LRServo.write(Pos);
//===================== Передача данных о координатах ========================
/*if (Serial.available() >0){
   char _Ch;
   _Ch = Serial.read();
  for (int i=0; i<No;i++){
    Serial.print (Coords[0][i],DEC);
    Serial.print(' ');
    Serial.println (Coords[1][i],DEC);
  }}*/
delay (10);
}

//**********************************************************************
//----------------------------------------------------------------------
//**********************************************************************
void getData(){
  int _leftVal=0;
  int _rightVal=0;
  int _leftVal1=0;
  int _rightVal1=0;
 
 digitalWrite (LedPin,HIGH);
 delayMicroseconds (100);
 _rightVal = analogRead(rightPin);
 _leftVal= analogRead (leftPin);
 digitalWrite (LedPin,LOW);
 delayMicroseconds (100);
 _rightVal1 = analogRead(rightPin);
 _leftVal1= analogRead (leftPin);
 rightVal = abs(_rightVal-_rightVal1);
 leftVal = abs( _leftVal-_leftVal1);

 }
//**********************************************************************
//----------------------------------------------------------------------
//**********************************************************************
void Scan(){
if (millis() >= ScanData.Time){
        //Serial.println (ScanData.i);
       	if (ScanData.Mode==0 && ScanData.on == true){ScanData.i++;}
	if (ScanData.Mode==1 && ScanData.on == true){ScanData.i--;}
	if (ScanData.i>=Array_Size){
            ScanData.on = false; 
            ScanData.Mode=1;
            ScanData.i=Array_Size /2; 
            Pos=ScanData.i*AngleScale;
            LRServo.write(Pos);
            analysis();
          
          }
	if (ScanData.i <=0){ScanData.Mode=0;}
	getData();
        //Serial.println (ScanData.i);
        Data [0][ScanData.i] = leftVal;
        Data [1][ScanData.i]=rightVal;


	if (ScanData.on == true) {Pos=ScanData.i*AngleScale;}
       ScanData.Time = millis()+ScanDelay;
}
 }
 //**********************************************************************
//----------------------------------------------------------------------
//**********************************************************************
void Detect() {
 getData();
  L=(millis()-Nav_Time)/Scale;

 if (((leftVal+rightVal)/2 ) > Min_Val && ScanData.on==false){
 //Stop();
 isObst=1;
 //=====================================================================================
  X=X+L* cos((Angle*3.141592654)/180);
 Y=Y+L*sin((Angle*3.141592654)/180);
 Coords[0][No]=X;
 Coords[1][No]=Y;
 No=No+1;
//=======================================================================================
 //ScanData.on=true;
 }  
 if ((leftVal+rightVal)/2  < Min_Val && ScanData.on==false){isObst=0;}//MoveForvard();}
 Scan();
}
//**********************************************************************
//----------------------------------------------------------------------
//********************************************************************** 
void analysis(){
  int _rightSum=0;
  int _leftSum=0;
for (int _i=0; _i<=Array_Size-1; _i++){
   // Serial.println ((Data[0][_i]+Data[1][_i])/2 ,DEC);}
}
for (int _i=0; _i<=44;_i++){
  _leftSum=_leftSum+(Data[0][_i]+Data[1][_i])/2;}
_leftSum=_leftSum/(45);

for (int _i=45; _i<=89;_i++){
  _rightSum=_rightSum+(Data[0][_i]+Data[1][_i])/2;}
_rightSum=_rightSum/(45);
//Serial.print (_leftSum);
//Serial.print (' ');
//Serial.print (_rightSum);
if (_leftSum < _rightSum){
    //Serial.println ("l");
    TurnLeft(90);
  }
if (_rightSum < _leftSum){
    //Serial.println("r");
    TurnRight(90);
 }
}
//===========================================================
void MoveForvard(){
 LServo.write (0);
 RServo.write (180);
} 

void MoveBack(){
 LServo.write (180);
 RServo.write (0);
}

void Stop(){
 LServo.write (Stop_Time);
 RServo.write (Stop_Time); 

  
}
void TurnLeft(int _angle){
 Angle=Angle+90;
 LServo.write (180);
 RServo.write(180);
 delay (_angle*Rot_Scale);
 LServo.write(Stop_Time);
 RServo.write(Stop_Time);
}

void TurnRight(int _angle){
  Angle=Angle-90;
 LServo.write (0);
 RServo.write(0);
 delay (_angle*Rot_Scale);
 LServo.write(Stop_Time);
 RServo.write(Stop_Time);
}

/*
Q7-Q8 Down A2 56
Q5-Q6 Right A0 54
Q3-Q4 Up A3 57
Q1-Q2 Left A2 55

*/

