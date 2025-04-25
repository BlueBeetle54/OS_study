//usage : imagemaker bootloader.bin kernel32.bin

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
//#include <io.h>                   //windows
#include <unistd.h>                 //unix
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

// no "O_BINARY" format in unix system
#ifndef O_BINARY
#define O_BINARY 0x00
#endif

#define BYTESOFSECTOR 512

int adjustInSectorSize(int Fd, int SourceSize){                 //fill 0x00 until sector end
    int i;
    int OverSectorSize = SourceSize % BYTESOFSECTOR;          //calc size beyond sector
    char Zero = 0x00;
    int SectorCount;

    if(OverSectorSize != 0){
        OverSectorSize = 512 - OverSectorSize;
        for(i=0; i<OverSectorSize; i++){
            write(Fd,&Zero, 1);
        }
    }
    return (SourceSize + OverSectorSize) / BYTESOFSECTOR;     //count file sector
}

void writeKernelInfo(int TargetFd, int KernelSectorCount){      //recode sector number to bootloader
    unsigned short Data;
    long Position = lseek(TargetFd, (off_t)5, SEEK_SET);        //sector number location = 0x5

    if(Position == -1){
        printf("[ERROR] lseek fail. errno: %d, %d\n", errno, SEEK_SET);
        exit(-1);
    }
    Data = (unsigned short) KernelSectorCount;
    write(TargetFd, &Data, 2);
}

int copyFile(int SourceFd, int TargetFd){                       //save whole file
    int SourceFileSize = 0;
    int Read, Write;
    char Buffer[BYTESOFSECTOR];

    while (1){
        Read = read(SourceFd, Buffer, sizeof(Buffer));
        Write = write(TargetFd, Buffer, Read);

        if(Read != Write){
            printf("[ERROR] File write error.\n");
            exit(-1);
        }
        SourceFileSize += Read;

        if(Read != sizeof(Buffer)){break;}
    }
    return SourceFileSize;
}

int main(int argc, char const *argv[]){
    int SourceFd;
    int TargetFd;
    int BootloaderSectorSize;
    int Kernel32SectorSize;
    int SourceSize;

    if (argc < 3){
        printf("[ERROR] argument require\n");
        exit(-1);
    }


    //create "disk.img" file
    if ((TargetFd = open("disk.img", O_RDWR | O_CREAT | O_TRUNC | O_BINARY, S_IREAD | S_IWRITE)) == -1){
        printf("[ERROR] disk.img open fail.\n");
        exit(-1);
    }


    //copy binary file
    if ((SourceFd = open(argv[1], O_RDONLY | O_BINARY)) == -1){
        printf("[ERROR] %s open fail\n", argv[1]);
        exit(-1);
    }
    SourceSize = copyFile(SourceFd, TargetFd);
    close(SourceFd);

    BootloaderSectorSize = adjustInSectorSize(TargetFd,SourceSize);
    printf("[INFO] %s size = [%d]\n", argv[1], SourceSize);


    //copy kernel file
    if ((SourceFd = open(argv[2], O_RDONLY | O_BINARY)) == -1){
        printf("[ERROR] %s open fail\n", argv[2]);
        exit(-1);
    }
    SourceSize = copyFile(SourceFd, TargetFd);
    close(SourceFd);

    Kernel32SectorSize = adjustInSectorSize(TargetFd,SourceSize);
    printf("[INFO] %s size = [%d]\n", argv[2], SourceSize);

    //write kernel image
    writeKernelInfo(TargetFd, Kernel32SectorSize);
    printf("[SUCCESS] Image file create complite");
    close(TargetFd);

    return 0;
}
