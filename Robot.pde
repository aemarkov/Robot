#include <Servo.h>
Servo LRServo;
Servo LServo;
Servo RServo;
//==========================
#define LedPin 12
#define rightPin 54
#define leftPin 55
//--------------------------
#define minVal 40
//--------------------------
#define Array_Size 90
#define ScanDelay 10
//--------------------------
#define Stop_Time 93
#define Rot_Scale 12 //милисекунд на градус
//==========================
int rightVal=0;
int leftVal=0;

int Data [2][Array_Size];
//--------------------------
int Pos=90;
float AngleScale=0;
int Angle =90;
//--------------------------
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
//**************************************************************
//==============================================================
//**************************************************************
void setup(){
  LRServo.attach(9);
  RServo.attach (10);
  LServo.attach (11);

  pinMode (LedPin,OUTPUT);
  Serial.begin(9600);
  //-------------------------
  AngleScale = 180/Array_Size;
}
//**************************************************************
//==============================================================
//**************************************************************
void loop(){
//getData();
//Serial.println(Detect(),DEC);
//Serial.println((leftVal+rightVal)/2);
int _D=0;
_D=Detect();
if (_D=1){ Serial.println(1,DEC);}
delay(10);
}
//**************************************************************
//==============================================================
//**************************************************************
void getData(){
 int _rightVal=0;
 int _leftVal=0;
 
 digitalWrite(LedPin,HIGH);
 delayMicroseconds(3000);
  
 _rightVal=analogRead(rightPin);
 _leftVal=analogRead(leftPin);
 
 delayMicroseconds(300);
 digitalWrite(LedPin,LOW);
 delayMicroseconds(300);
 
 rightVal=abs(_rightVal-analogRead(rightPin));
 leftVal=abs(_leftVal-analogRead(leftPin));  
}
//**************************************************************
//==============================================================
//**************************************************************
byte Detect(){
  getData();
  static int _n=0; 
 // Serial.print (_n);
  if (((leftVal+rightVal)/2)>minVal){_n++;}
  if (((leftVal+rightVal)/2)<(minVal-5)){_n=0;}
  if (_n>=10){return 1;} else {return 0;}
  
}
//**************************************************************
//==============================================================
//**************************************************************
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
 
//**************************************************************
//==============================================================
//************************************************************** 
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
