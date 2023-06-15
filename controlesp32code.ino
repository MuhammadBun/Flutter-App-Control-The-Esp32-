#include <Arduino.h>
#include <WiFi.h>  
#include <WebSocketsServer.h> 
#include<stdio.h>
#include <stdlib.h>
#include <string.h>
int ledpin = 22; 
int ledpin1 = 5; 
int duty = 0;
int duty1 = 0;
int d= 0;
const int freq = 90; // 5000 Hz
const int ledChannel = 0;
const int resolution = 8;  
const int ledChannel2 = 1;
const char *ssid =  "DCwifiPRo";   
const char *pass =  "123456789";  
#define USE_SERIAL Serial1
WebSocketsServer webSocket = WebSocketsServer(81); 
void hexdump(const void *mem, uint32_t len, uint8_t cols = 16) {
  const uint8_t* src = (const uint8_t*) mem;
  USE_SERIAL.printf("\n[HEXDUMP] Address: 0x%08X len: 0x%X (%d)", (ptrdiff_t)src, len, len);
  for(uint32_t i = 0; i < len; i++) {
    if(i % cols == 0) {
      USE_SERIAL.printf("\n[0x%08X] 0x%08X: ", (ptrdiff_t)src, i);
    }
    USE_SERIAL.printf("%02X ", *src);
    src++;
  }
  USE_SERIAL.printf("\n");
}
void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
    char cmd[4] = "";
    char myDuty[3] = "";
  
    switch(type) {
        case WStype_DISCONNECTED:
            Serial.println("Websocket is disconnected");
            //case when Websocket is disconnected
            break;
        case WStype_CONNECTED:{
            //wcase when websocket is connected
            Serial.println("Websocket is connected");
            Serial.println(webSocket.remoteIP(num).toString());
            webSocket.sendTXT(num, "connected");}
            break;
        case WStype_TEXT:
             //merging payload to single string
                
             for(int i = 0; i < length; i++) {
                   cmd[i]  = (char) payload[i];                     
                  }
             d = atoi(cmd);
             if(cmd[0] == 'A'){duty = 0;}
             if(cmd[0] == 'B'){duty = 1;}
 
     Serial.println(atoi(cmd));
            break;
        case WStype_FRAGMENT_TEXT_START:
            break;
        case WStype_FRAGMENT_BIN_START:
            break;
        case WStype_BIN:
            hexdump(payload, length);
            break;
        default:
            break;
    }

}
void setup() {
   pinMode(ledpin, OUTPUT);  
   pinMode(ledpin1, OUTPUT);  
   ledcSetup(ledChannel, freq, resolution);
   ledcAttachPin(ledpin, ledChannel);
   ledcAttachPin(ledpin1, ledChannel2);
   Serial.begin(9600);  
   Serial.println("Connecting to wifi");   
   IPAddress apIP(192, 168, 0, 1);  
   WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0)); 
   WiFi.softAP(ssid, pass);
   webSocket.begin();
   webSocket.onEvent(webSocketEvent); 
   Serial.println("Websocket is started");
}

void loop() { 
  if(duty  == 1   ){ 
    ledcWrite(ledChannel,  d*2.55);   
    ledcWrite(ledChannel2, 0);
    }else{
           ledcWrite(ledChannel2,  d*2.55);   
           ledcWrite(ledChannel, 0);
           } 
 webSocket.loop();   
}
