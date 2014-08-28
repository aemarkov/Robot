#include <Servo.h>
Servo LRServo;
Servo LServo;
Servo RServo;
//==========================
#define LedPin 12
#define rightPin 54
#define leftPin 55
//--------------------------
#define minVal 120
//--------------------------
#define Array_Size 90
#define ScanDelay 10
//------------- Боковые датчики -------------
byte sideLEDPin [2]={2,3};
byte sidePin[2]={57,58};
int sideVal [2]={0,0};
//-------------------------------------------
#define Stop_Time 91
#define Rot_Scale 11 //милисекунд на градус
#define DScale 0.0015
float Scale = DScale; //ms for point
//==========================
int rightVal=0;
int leftVal=0;

int Data [2][Array_Size];
int Pos=90;
float AngleScale=0;
//------------------- НАВИГАЦИЯ -----
int Angle =90;
int Bearing =0;
byte X =128;
byte Y=128;
long int Nav_Time=0; 
byte Points [2][10];  //Координаты точек  
byte NofPoints;        //Кол-во точек
byte CurNo=0;         //Номер текущей точки
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
  LRServo.write(90);
  LRServo.write(Pos);
  pinMode (LedPin,OUTPUT);
  Serial.begin(9600);
  //-------------------------
  AngleScale = 180/Array_Size;
  getPoints();
  pinMode(13,OUTPUT);
  //delay(5000);
}
//**************************************************************
//==============================================================
//**************************************************************
void loop(){
getAdvData();
Serial.print (sidePin[0],DEC);
Serial.print (" ");
Serial.println (analogRead(57), DEC);

delay(2);
}
//**************************************************************
//==============================================================
//**************************************************************
void getAdvData(){
 int _firstVal[2]={0,0};

 
 int _secondVal[2]={0,0};
 
 int _sumVal[2]={0,0};
 
 int _k=5;
 for (int _i=0; _i<=_k-1; _i++){
   
 digitalWrite(sideLEDPin[0],HIGH);
 digitalWrite(sideLEDPin[1],HIGH);
 delayMicroseconds(10);
  
_firstVal[0]=analogRead(sidePin[0]);
_firstVal[1]=analogRead(sidePin[1]);
 
 digitalWrite(sideLEDPin[0],LOW);
 digitalWrite(sideLEDPin[1],LOW);
 delayMicroseconds(10);
 
 _secondVal[0]=abs(_firstVal[0]-analogRead(sidePin[0]));
 _secondVal[1]=abs(_firstVal[1]-analogRead(sidePin[1]));  
 
 _sumVal[0]=_sumVal[0]+_secondVal[0];
 _sumVal[1]=_sumVal[1]+_secondVal[1];
 }
 sideVal[0]=_sumVal[0]/_k;
sideVal[1]=_sumVal[1]/_k;


}
//**************************************************************
//==============================================================
//**************************************************************
void getData(){
 int _rightVal=0;
 int _leftVal=0;
 
 int _rightVal1=0;
 int _leftVal1=0;
 
 int _leftVal2 =0;
 int _rightVal2 =0;
 int _k=5;
 for (int _i=0; _i<=_k-1; _i++){
   
 digitalWrite(LedPin,HIGH);
 delayMicroseconds(10);
  
 _rightVal1=analogRead(rightPin);
 _leftVal1=analogRead(leftPin);
 
 digitalWrite(LedPin,LOW);
 delayMicroseconds(10);
 
 _rightVal2=abs(_rightVal1-analogRead(rightPin));
 _leftVal2=abs(_leftVal1-analogRead(leftPin));  
 
 _rightVal=_rightVal+_rightVal2;
 _leftVal=_leftVal+_leftVal2;
 }
 leftVal=_leftVal/_k;
rightVal=_rightVal/_k;

}
//**************************************************************
//==============================================================
//**************************************************************
byte Detect(){
  getData();
  if ((leftVal+rightVal)/2 > minVal){return 1;} else {return 0;}
}
//**************************************************************
//==============================================================
//**************************************************************
 boolean Scan(){
   //Serial.println (ScanData.i);
   boolean RVal=false;
  //Serial.println (ScanData.on, DEC);
  if (ScanData.on == true && ScanData.Mode == 0){
   ScanData.i=0;
   Pos=ScanData.i*AngleScale;
   LRServo.write (Pos);
   delay (650);
   ScanData.Mode = 1;
  } 
  if (ScanData.on == true && ScanData.Mode == 1){
    if (ScanData.i<Array_Size){
      ScanData.i++;
      Pos=ScanData.i*AngleScale;
      LRServo.write(Pos);
      delay(3);
      getData();
      Data [0][ScanData.i] = leftVal;
      Data [1][ScanData.i]=rightVal;
    }
   if (ScanData.i>=Array_Size){
     ScanData.i=Array_Size/2;
     Pos=90;
     LRServo.write (Pos);
     ScanData.Mode=0;
     ScanData.on=false;
     delay(650);
      RVal = true; 
     //analysis();
   }  
 }
 return RVal;
 }
//**************************************************************
//==============================================================
//************************************************************** 
boolean analysis(byte _mode){
    boolean _isObst=false;
/*  int _rightSum=0;
  int _leftSum=0;
//for (int _i=0; _i<=Array_Size-1; _i++){
   // Serial.println ((Data[0][_i]+Data[1][_i])/2 ,DEC);}

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
 }*/
 if (_mode == 0){
     int _MaxVal=0;
     int _V=0;
     byte _ang=0;
     for (int _i=0; _i<=Array_Size-1; _i++){
        _V=(Data[0][_i]+Data[1][_i])/2;
        if (_V>=minVal){_isObst=true;}
        if (_MaxVal<_V && _V > minVal){_MaxVal=_V; _ang=_i*AngleScale;}
      }
   //byte _R=0;
  //_R= random (0,1);
 //if (_R==1){TurnLeft(90); Serial.println ("_TL 90");} else {TurnRight(90); Serial.println("_TR 90");}
  if(_ang<90){TurnRight(_ang);} else{TurnLeft(180-_ang);}
  
   
 }
 //==========================================================
 if (_mode == 1){  //Ищем препятствие слева
  int _MaxVal=0;
  int _V=0;
  byte _ang=0;
  
  for (int _i=0; _i<=Array_Size/2-1; _i++){
    _V=(Data[0][_i]+Data[1][_i])/2;
  if (_V>=minVal){_isObst=true;}
    if (_MaxVal<_V && _V > minVal){_MaxVal=_V; _ang=_i*AngleScale;}
  }
  //Serial.println (_ang, DEC);
  if (_isObst){TurnRight(_ang);Serial.println (_ang,DEC);}
 }
//===========================================================
 if (_mode == 2){  //Ищем препятствие слева
  int _MaxVal=0;
  int _V=0;
  byte _ang=0;
  
  for (int _i=Array_Size/2; _i<=Array_Size; _i++){
    _V=(Data[0][_i]+Data[1][_i])/2;
  if (_V>=minVal){_isObst=true;}
    if (_MaxVal<_V && _V > minVal){_MaxVal=_V; _ang=_i*AngleScale;}
  }
  if (_isObst){TurnLeft(180-_ang); Serial.println (180-_ang,DEC);}
 }
//Serial.println (_isObst);
 return (_isObst);
}
//===========================================================
void MoveForward(){
 LServo.write (0);
 RServo.write (180);
 Scale=DScale;
} 

void MoveBack(){
 LServo.write (180);
 RServo.write (0);
}

void Stop(){
 LServo.write (Stop_Time);
 RServo.write (Stop_Time); 
 Scale=0;
  
}
void TurnLeft(int _angle){
 Angle=Angle+_angle;
 Serial.print (" "); Angle=AngleTR(Angle);
 LServo.write (180);
 RServo.write(180);
 delay (abs(_angle)*Rot_Scale);
 LServo.write(Stop_Time);
 RServo.write(Stop_Time);
 Nav_Time=millis();
}

void TurnRight(int _angle){
  Angle=Angle-_angle;

  Angle=AngleTR(Angle);
  LServo.write (0);
 RServo.write(0);
delay (abs(_angle)*Rot_Scale);
 LServo.write(Stop_Time);
 RServo.write(Stop_Time);
 Nav_Time=millis();
}


//**************************************************************
//==============================================================
//************************************************************** 
void getPoints(){
 NofPoints = 4;
 Points [0][0]=128;
 Points [1][0]=190;
 
 Points [0][1]=190;
 Points [1][1]=190;
 
 Points [0][2]=190;
 Points[1][2]=128;
 
 Points[0][3] = 128;
 Points[1][3]=128;
 CurNo=0;
 
  
}

//=======================================================
//======================================================
int AngleTR(int _Angle){
	double _A=0;
	int _A1=0;
	if (abs(_Angle)>180 || abs(_Angle)<0){
		_A=_Angle/180;
		if (_Angle>0) {
			_A1=(int) floor(_A) % 2;
			if (_A1 == 0){
				_Angle = _Angle - (int) floor(_A)*180;}
			else {
				_Angle=-180+(_Angle-(int)floor(_A)*180); }
		}
		 else{
			_A1=(int) ceil(_A) % 2;
			if (_A1==0){
				_Angle = _Angle + int(ceil(_A)*180);
			}else {
				_Angle = 180+(_Angle+(int)(abs(ceil(_A)*180)));
			}
		}
	}
return _Angle;
}
int freeRam () {
  extern int __heap_start, *__brkval; 
  int v; 
  return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval); 
}

/*
сейчас включу смотри как будетзнак меньше -5 - значит проехал линию
*/
