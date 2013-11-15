//**********************************************************************//
//                                                                      //
//                            PLAY'D                                    //
//                        code version 0.1                              //
//                                                                      //
// PLAYD'D code for use with a 4x4 Arduino-controlled Play'D            //
// This version has 5 push-sensors, 4 independent light-connections,    //
// 2 speakers and 1 vibration actuator                                  //
//                                                                      //
// code by Viktor de Boer 2009                                          //
//                                                                      //
//**********************************************************************//

int ledPinB2RY = 2; // red/yellow lights on B2
int ledPinB2G = 3; // green lights on B2
int ledPinC3Y = 4; // yellow lights on C3
int ledPinC3R = 5; // red lights on C3

int currentMode = 0;   // The current mode (0=movement, 1=instrument)
int modeButtonVal=0;
int modeButton = 7; // pin for modebutton
int mode2Mode = 0;  // mode within mode 2

int testLedPin = 13;   // test led, changes at push and mode change
int statePin = LOW;   // variable used to store the last LED status, to toggle the light

int speakerPinL = 9;      // Left speaker
int speakerPinR = 11;     // Right speaker

int vibraPin = 10;

// Push sensors
int knockSensorA2 = 0;  // this knock sensor will be plugged at analog pin 0
int knockSensorB2 = 1;  // this knock sensor will be plugged at analog pin 1
int knockSensorC2 = 2;  // this knock sensor will be plugged at analog pin 2
int knockSensorD2 = 3;  //
int knockSensorC3 = 4;  //

byte valA2 = 0;         // variable to store the value read from the sensor pin
byte valB2 = 0;         // variable to store the value read from the sensor pin
byte valC2 = 0;         // variable to store the value read from the sensor pin
byte valD2 = 0;
byte valC3 = 0;

int THRESHOLD = 25;  // threshold value to decide when the detected sound is a knock or not
int lpArray[5] = {99,99,99,99,99}; // last pushed knockSensors (start =99)


// music globals
int length = 15; // the number of notes
char notes0[] = "CCCgaageeddC"; // a space represents a rest "CCCgaageeddC "
char notes1[] = "ccggaagffeeddc"; // a space represents a rest "ccggaagffeeddc "
int beats[] = { 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 4 };
int tempo = 300;



void setup() {
  // declare input/outputs (knock sensors on analog input: do not need to be declared)
     pinMode(ledPinB2RY,OUTPUT);
     pinMode(ledPinB2G,OUTPUT);
     pinMode(ledPinC3Y,OUTPUT);
     pinMode(ledPinC3R,OUTPUT);
     pinMode(testLedPin,OUTPUT);
     pinMode(speakerPinL, OUTPUT);
     pinMode(speakerPinR, OUTPUT);
     pinMode(vibraPin, OUTPUT);
     pinMode(modeButton, INPUT); 

    // say hi over serial connection
     Serial.begin(9600);
     Serial.println("Play'D says hi!");
}

void loop() {
  
  // Switch modes on button push
  modeButtonVal = digitalRead(modeButton);
  // Serial.print(modeButtonVal);
  if (modeButtonVal==HIGH){
        if (currentMode==2){
          currentMode=0;
        }
        else if (currentMode==0){
          currentMode=1; 
          resetArray();
        }
        else if (currentMode==1){
          currentMode=2;
          mode2Mode=0;
        }
        Serial.print("Mode switched to ");
        Serial.println(currentMode);
        digitalWrite(testLedPin, HIGH); // turn the led on or off
        delay(500);
        digitalWrite(testLedPin, LOW); // turn the led on or off
        delay(500);
        digitalWrite(testLedPin, HIGH);// turn the led on or off
        delay(500);
        digitalWrite(testLedPin, LOW); // turn the led on or off
        delay(500);
        
  }
    // *********************************    MODE 0   ***************************************
  if(currentMode==0){
  
  valA2 = analogRead(knockSensorA2);    // read the sensor and store it in the variable "val"
  valB2 = analogRead(knockSensorB2);    // read the sensor and store it in the variable "val"
  valC2 = analogRead(knockSensorC2);    // read the sensor and store it in the variable "val"
  valD2 = analogRead(knockSensorD2);    // read the sensor and store it in the variable "val"
  valC3 = analogRead(knockSensorC3);    // read the sensor and store it in the variable "val"
  
  if (valA2 >= THRESHOLD) {
    statePin = !statePin;           // toggle the status of the ledPin (this trick doesn't use time cycles)
    digitalWrite(testLedPin, statePin); // turn the led on or off
    delay(100);  // we have to make a delay to avoid overloading the serial port
    if (lpArray[0] !=0){push(0);    processLP();}   // if the pushed button is not the same as last time, add to array
  }
  
  if (valB2 >= THRESHOLD) {
    // toggle light show at B2
    lightshowB2();
    statePin = !statePin;           // toggle the status of the ledPin (this trick doesn't use time cycles)
    digitalWrite(testLedPin, statePin); // turn the led on or off
    delay(100);  // we have to make a delay to avoid overloading the serial port
    if (lpArray[0] !=1) {push(1);    processLP();}
  }
  
  if (valC2 >= THRESHOLD) {
    statePin = !statePin;           // toggle the status of the ledPin (this trick doesn't use time cycles)
    digitalWrite(testLedPin, statePin); // turn the led on or off
    delay(100);  // we have to make a delay to avoid overloading the serial port
    if (lpArray[0] !=2){push(2);    processLP();}

  }
 
  if (valD2 >= THRESHOLD) {
    // toggle light show at B2
    statePin = !statePin;           // toggle the status of the ledPin (this trick doesn't use time cycles)
    digitalWrite(testLedPin, statePin); // turn the led on or off
    delay(100);  // we have to make a delay to avoid overloading the serial port
    if (lpArray[0] !=3) {push(3);    processLP();}
  }
  
  if (valC3 >= THRESHOLD) {
    lightshowC3();
    statePin = !statePin;           // toggle the status of the ledPin (this trick doesn't use time cycles)
    digitalWrite(testLedPin, statePin); // turn the led on or off
    delay(100);  // we have to make a delay to avoid overloading the serial port
    if (lpArray[0] !=4){push(4);    processLP();}

  }
  delay(100);  // we have to make a delay to avoid overloading the serial port
  }
  
  
  // *********************************    MODE 1   ***************************************
  if (currentMode==1){
        
    
  valA2 = analogRead(knockSensorA2);    // read the sensor and store it in the variable "val"
  valB2 = analogRead(knockSensorB2);    // read the sensor and store it in the variable "val"
  valC2 = analogRead(knockSensorC2);    // read the sensor and store it in the variable "val"
  valD2 = analogRead(knockSensorD2);    // read the sensor and store it in the variable "val"
  valC3 = analogRead(knockSensorC3);    // read the sensor and store it in the variable "val"
  
 if (valA2 >= THRESHOLD) {
    playNote(speakerPinL, 'a', 200);
    Serial.println("A2->a");
    delay(50);  // we have to make a delay to avoid overloading the serial port
  }
 if (valB2 >= THRESHOLD) {
    flashB2();
    playNote(speakerPinL, 'b', 200);
    Serial.println("B2->B plus lights");
    delay(50);  // we have to make a delay to avoid overloading the serial port
  } 
  if (valC2 >= THRESHOLD) {
    playNote(speakerPinR, 'c', 200);
    Serial.println("C2->c");
    delay(50);  // we have to make a delay to avoid overloading the serial port
  } 
  if (valD2 >= THRESHOLD) {
    playNote(speakerPinR, 'd', 200);
    Serial.println("D2->d");
    delay(50);  // we have to make a delay to avoid overloading the serial port
  } 
  if (valC3 >= THRESHOLD) {
    flashC3();
    playNote(speakerPinL, 'e', 200);
    Serial.println("C3->e plus lights");
    delay(50);  // we have to make a delay to avoid overloading the serial port
  }
  
  delay(50);  // we have to make a delay to avoid overloading the serial port
  
} // close mode 1


  // *********************************    MODE 2   ***************************************
  // choose a square at random (for now only B2 or C3) and flash it until right square is pushed.
  // in that case, vibrate for X seconds, then choose anew.
  
  if (currentMode==2){
    
    // found / choosing mode
    if (mode2Mode == 0){
      Serial.println("BRRRRRRRR");
      vibrateLong();
      mode2Mode = random(1,3); // choose at random
      Serial.print("look for ");
      Serial.println(mode2Mode);
      delay(50);
    }
    // push B2 mode
    else if (mode2Mode == 1){
      valB2 = analogRead(knockSensorB2);    // read the sensor and store it in the variable "val"
      if (valB2 >= THRESHOLD) {
        mode2Mode = 0;                      // go to found mode
        Serial.println("B2 found!");
        delay(50);  // we have to make a delay to avoid overloading the serial port
      } 
      else{
        flashB2();
        delay(500);
      }
    }
    // push C3 mode
    else if (mode2Mode == 2){
      valC3 = analogRead(knockSensorC3);    // read the sensor and store it in the variable "val"
      if (valC3 >= THRESHOLD) {
        mode2Mode = 0;                      // go to found mode
        Serial.println("C3 found!");
        delay(50);                          // we have to make a delay to avoid overloading the serial port
      } 
      else{
        flashC3();
        delay(500);
      } 
    }
    delay(50);
  }// close mode 2

} // close loop
// ********************  Supporting functions  *****************************

// Array-functions
// push int on array
void push(int i){
    lpArray[4] = lpArray[3];
    lpArray[3] = lpArray[2];
    lpArray[2] = lpArray[1];
    lpArray[1] = lpArray[0];
    lpArray[0] = i;
    Serial.print(lpArray[0]);
    Serial.print(lpArray[1]);
    Serial.print(lpArray[2]);
    Serial.print(lpArray[3]);
    Serial.println(lpArray[4]);
}

void resetArray(){
          lpArray[0] = 99; 
          lpArray[1] = 99; 
          lpArray[2] = 99; 
          lpArray[3] = 99; 
          lpArray[4] = 99; 
        }
// process the array
 void processLP(){
     int a = lpArray[0];
     int b = lpArray[1];
     int c = lpArray[2];
    if (a==0 && b==1 && c==2){
        lightshowB2();
        playSong(speakerPinR,0);
        Serial.print("playing right");   
    }
    if (a==3 && b==2 && c==1){
        lightshowC3;
        playSong(speakerPinL,1);
        Serial.print("playing left");   
    }
 }
 
 
 //****************   Play music  *******************************
/* Melody
 * (cleft) 2005 D. Cuartielles for K3
 *
 * This example uses a piezo speaker to play melodies.  It sends
 * a square wave of the appropriate frequency to the piezo, generating
 * the corresponding tone.
 *
 * The calculation of the tones is made following the mathematical
 * operation:
 *
 *       timeHigh = period / 2 = 1 / (2 * toneFrequency)
 *
 * where the different tones are described as in the table:
 *
 * note 	frequency 	period 	timeHigh
 * c 	        261 Hz 	        3830 	1915 	
 * d 	        294 Hz 	        3400 	1700 	
 * e 	        329 Hz 	        3038 	1519 	
 * f 	        349 Hz 	        2864 	1432 	
 * g 	        392 Hz 	        2550 	1275 	
 * a 	        440 Hz 	        2272 	1136 	
 * b 	        493 Hz 	        2028	1014	
 * C	        523 Hz	        1912 	956
 *
 * http://www.arduino.cc/en/Tutorial/Melody
 */
  


void playTone(int speakerPinX, int tone, int duration) {
  for (long i = 0; i < duration * 1000L; i += tone * 2) {
    digitalWrite(speakerPinX, HIGH);
    delayMicroseconds(tone);
    digitalWrite(speakerPinX, LOW);
    delayMicroseconds(tone);
  }
}

void playNote(int speakerPinX, char note, int duration) {
  char names[] = { 'c', 'd', 'e', 'f', 'g', 'a', 'b', 'C' };
  int tones[] = { 1915, 1700, 1519, 1432, 1275, 1136, 1014, 956 };
  
  // play the tone corresponding to the note name
  for (int i = 0; i < 8; i++) {
    if (names[i] == note) {
      playTone(speakerPinX, tones[i], duration);
    }
  }
}


void playSong(int speakerPinX, int whichSong) {
  
  if (whichSong==0){   
  for (int i = 0; i < length; i++) {
    if (notes0[i] == ' ') {
      delay(beats[i] * tempo); // rest
    } else {
      playNote(speakerPinX, notes0[i], beats[i] * tempo);
    }
    
    // pause between notes
    delay(tempo / 2); 
    }
  }

if (whichSong==1){ 
  
  for (int i = 0; i < length; i++) {
    if (notes1[i] == ' ') {
      delay(beats[i] * tempo); // rest
    } else {
      playNote(speakerPinX, notes1[i], beats[i] * tempo);
    }
    
    // pause between notes
    delay(tempo / 2); 
    }
  }


  }

// *************************** Light Show   *******************************************


// light show at B2
void lightshowB2(){
  digitalWrite(ledPinB2RY,HIGH); delay(200); digitalWrite(ledPinB2RY,LOW); delay(200); 
  digitalWrite(ledPinB2G,HIGH); delay(200); digitalWrite(ledPinB2G,LOW); delay(200); 
  digitalWrite(ledPinB2RY,HIGH); delay(200); digitalWrite(ledPinB2RY,LOW); delay(200); 
  digitalWrite(ledPinB2G,HIGH); delay(200); digitalWrite(ledPinB2G,LOW); delay(200); 
  digitalWrite(ledPinB2RY,HIGH); delay(200); digitalWrite(ledPinB2RY,LOW); delay(200); 
  digitalWrite(ledPinB2G,HIGH); delay(200); digitalWrite(ledPinB2G,LOW); delay(200); 
} 

// light show at C3
void lightshowC3(){
  digitalWrite(ledPinC3Y,HIGH); delay(200); digitalWrite(ledPinC3Y,LOW); delay(200); 
  digitalWrite(ledPinC3R,HIGH); delay(200); digitalWrite(ledPinC3R,LOW); delay(200); 
  digitalWrite(ledPinC3Y,HIGH); delay(200); digitalWrite(ledPinC3Y,LOW); delay(200); 
  digitalWrite(ledPinC3R,HIGH); delay(200); digitalWrite(ledPinC3R,LOW); delay(200); 
  digitalWrite(ledPinC3Y,HIGH); delay(200); digitalWrite(ledPinC3Y,LOW); delay(200); 
  digitalWrite(ledPinC3R,HIGH); delay(200); digitalWrite(ledPinC3R,LOW); delay(200); 
} 

// briefly flash all lights at B2
void flashB2(){
      digitalWrite(ledPinB2RY,HIGH); 
      digitalWrite(ledPinB2G,HIGH); 
      delay(50); 
      digitalWrite(ledPinB2RY,LOW); 
      digitalWrite(ledPinB2G,LOW);
}

// briefly flash all lights at C3
void flashC3(){  
      digitalWrite(ledPinC3Y,HIGH); 
      digitalWrite(ledPinC3R,HIGH); 
      delay(50); 
      digitalWrite(ledPinC3Y,LOW); 
      digitalWrite(ledPinC3R,LOW);
}


// ************************ Vibration **************************

void vibrateLong(){
  digitalWrite(vibraPin,HIGH);
  delay(2000);
  digitalWrite(vibraPin, LOW);
}
