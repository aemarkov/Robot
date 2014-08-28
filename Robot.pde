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
//--------------------------
#define Stop_Time 90
#define Rot_Scale 9 //милисекунд на градус
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
  delay(5000);
}
//**************************************************************
//==============================================================
//**************************************************************
void loop(){
//int _D=0;
int _X=0;
int _Y=0;

if (!(CurNo>NofPoints-1)){
_X=Points[0][CurNo];  // Получаем координаты след. Точки
_Y=Points[1][CurNo];  //

// Вычисляем свои координаты
int _XX=0;
int _YY=0;
_XX=(millis()-Nav_Time)*(double) cos((double)Angle*3.145926/180)*Scale;
_YY=(millis()-Nav_Time)*(double) sin((double)Angle*3.145926/180)*Scale;
X=X+_XX;
Y=Y+_YY;
if (millis()-Nav_Time > 1000){Nav_Time=millis();}

if (sqrt ((_X-X)*(_X-X)+(_Y-Y)*(_Y-Y)) < 1) {
  CurNo++;
  if (CurNo<=NofPoints-1){
   digitalWrite(13,HIGH);
   delay(200);
   digitalWrite(13,LOW);
  _X=Points[0][CurNo];  // Получаем координаты след. Точки
  _Y=Points[1][CurNo];}

delay(50);

 Serial.print ("Chekpoint! ");
 Serial.println (CurNo);
}
//Вычисление курса на точку

if (abs(X-_X)<=1 && _Y>Y){Bearing =  90 -Angle;}
if (abs(X-_X)<=1 && _Y<Y){Bearing=-90-Angle;}
if (abs(_Y-Y)<=1 && _X>X){Bearing = 0 - Angle;}
if (abs(_Y-Y)<=1 && _X<X){Bearing = 180-Angle;}
if (_Y!=Y && _X!=X){
  Bearing =atan((_Y-Y)/(_X-X))*180/3.1415926;
  
if (_X-X>1 && _Y-Y>1){Bearing=Bearing-Angle;}
if (_X-X<-1 && _Y-Y>1){Bearing=Bearing+90-Angle; }
if (_X-X>1 && _Y-Y<-1){Bearing=-Bearing-Angle;}
if (_X-X<-1 && _Y-Y<-1){Bearing=-(Bearing+90-Angle);}
}

Bearing = AngleTR(Bearing);


/*Serial.print (X, DEC);
Serial.print (' ');
Serial.print (Y, DEC);
Serial.print (' ');
Serial.print (_X);
Serial.print (' ');
Serial.print (_Y);
Serial.print (' ');
Serial.print (Angle);
Serial.print(' ');
Serial.println (Bearing);
*/

if (abs(0-Bearing)<5){
    Serial.println ("[-5,5]");
if (Detect()==0 ){MoveForward();Serial.println ("Go Forward");}
 else{
   Serial.print ("Turn ");
  // Serial.println ((leftVal+rightVal)/2);
   
  //byte _R=2;
  //_R= random (0,1);
  Stop();
  boolean B;
  ScanData.on = true;
  do {
      B=Scan();
     delay(5);
  } while (B==false);
//Serial.println(ScanData.i, DEC);
  if (B==true){analysis(0); MoveForward(); Delay(1000);     Nav_Time=millis();}
 }
 
}


if (Bearing < -5){
  Stop();
   Serial.println ("<-5");
  Scale=0;
  ScanData.on = true;
  boolean B;
  B=Scan();
  if (B==true){
    if (analysis(2)){
      Serial.println ("Right prepyatstv");    
      delay (300); 
      MoveForward();  
      Delay(2000); 
      Nav_Time=millis();
      Nav_Time = millis();} else {
      Serial.print ("TurnRight ");
      Serial.println (Bearing);
      TurnRight(abs(Bearing));
      Bearing = 0;
         MoveForward();  
     Delay(2000);
     Nav_Time=millis();
  }
  }
}

if (Bearing > 5){
  //Serial.println (">5");
  Stop();
  Scale=0;
  ScanData.on = true;
  boolean B;
  B=Scan();
  if (B==true){
   if (analysis(1)){ 
     Serial.println ("Left prepyatstv");   
      delay (300); 
     MoveForward();  
     Delay(2000); 
          Nav_Time=millis();
     Nav_Time = millis();} else {
       Serial.print ("TurnRight ");
      Serial.println (Bearing);
     TurnLeft(abs(Bearing));
          Bearing=0;  
      MoveForward();  
     Delay(2000);
          Nav_Time=millis();
 }
}
}

//ScanData.on=true;
//boolean A;
//A=Scan();
} else {Stop();
digitalWrite(13,HIGH);
delay(100);
digitalWrite(13,LOW);
delay(100);
}
delay(2);
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
//======================================================================
//**********************************************************************
//=====================================================================
void Delay(int _millis){
  int _i=0;
  byte _V=0;
do {
  _V=Detect();
  _i++;
} while ((_i<=_millis-1) && (_V==0));

}
int freeRam () {
  extern int __heap_start, *__brkval; 
  int v; 
  return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval); 
}

/*
сейчас включу смотри как будетзнак меньше -5 - значит проехал линию
*/
