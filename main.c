#include "Types.h"

void kPrintString(int X, int Y, const char* output);

void main(){
    kPrintString(0, 3, "OS kernel start.");
    while (1);
}

void kPrintString(int X, int Y, const char* output){
    CHARACTER* videoMemory = (CHARACTER*) 0xB8000;
    int i;

    videoMemory += (Y * 80) + X;
    for (i = 0; output[i] != 0; i++){
        videoMemory[i].bCharacter = output[i];
    }
}