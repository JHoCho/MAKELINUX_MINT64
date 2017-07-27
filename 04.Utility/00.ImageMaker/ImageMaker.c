#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

#define BYTESOFSECTOR 512

//함수선언
int AdjustInSectorSize(int iFd,int iSourceSize);
void WriteKernelInformation(int iTargetFd,int iKernelSectorCount);
int CopyFile(int iSource, int iTargetFd);

int main(int argc,char* argv[])
{
	int iSourceFd;
	int iTargetFd;
	int iBootLoaderSize;
	int iKernel32SectorCount;
	int iSourceSize;

	if(argc <3)
	{
		fprintf(stderr,"[ERROR] ImageMaker.exe BootLoader.bin Kernel32.bin\n");
		exit(-1);
	}
	//Disk.img파일을 생성
	if((iTargetFd = open ("Disk.img",O_RDWR|O_CREAT|O_TRUNC))==-1)
	{
		fprintf(stderr,"[ERROR] Disk.img open fail.\n");
		exit(-1);
	}
	//-----------------------------------------------------------
	//	부트 로더 파일을 열어서 모든 내용을 디스크 이미지 파일로 복사
	//-----------------------------------------------------------
	printf("[INFO] Copy boot loader to image file\n");
	if((iSourceFd=open(argv[1],O_RDONLY))==-1)
	{
		fprintf(stderr,"[ERROR]$s open fail \n",argv[1]);
		exit(-1);

	}
	iSourceSize = CopyFile(iSourceFd,iTargetFd);
	close(iSourceFd);
	//파일 크기를 섹터 크기인 512 바이트로 맞추기 위해 나머지 부분을 0x00으로 채움
	iBootLoaderSize = AdjustInSectorSize(iTargetFd, iSourceSize);
	printf("[INFO] $s size = [%d] and sector count = [%d]\n",argv[1],iSourceSize,iBootLoaderSize);
		//-----------------------------------------------------------
		//	32 비트 커널 파일을 열어서 모든 내용을 디스크 이미지 파일로 복사
		//-----------------------------------------------------------

	printf("[INFO] Copy protected mode kernel to image file\n");
	if((iSourceFd = open(argv[2],O_RDONLY))==-1)
	{
		fprintf(stderr,"[ERROR]%s open fail\n",argv[2]);
		exit(-1);
	}
	iSourceSize = CopyFile(iSourceFd,iTargetFd);
	close(iSourceFd);
	//now I'm trying to write English cuz SourceTree which is program for git is not work well for korean though
	//fill 0x00 with extras to set file size 512 as the size of sector
	iKernel32SectorCount = AdjustInSectorSize(iTargetFd, iSourceSize);
	printf("[INFO]%s size = [%d] and sector count = [%d]\n",argv[2],iSourceSize,iKernel32SectorCount);
	//-----------------------------------------------------------
	//	reloading information to disk image
	//-----------------------------------------------------------
	printf("Start to write kernel information\n");
	// read information for kernel at 5th byte on bootSector //

	close(iTargetFd);
	return 0;
}
// this will fill 0x00 from here to 512 byte's point
int AdjustInSectorSize(int iFd,int iSourceSize)
{
	int i;
	int iAdjustSizeToSector;
	char cCh;
	int iSectorCount;

	iAdjustSizeToSector = iSourceSize % BYTESOFSECTOR;
	cCh = 0x00;
	if(iAdjustSizeToSector !=0)
	{
		iAdjustSizeToSector = 512 - iAdjustSizeToSector;
		printf("[INFO] File size[%lu]and file [%u]byte \n",iSourceSize,iAdjustSizeToSector);
		for(i=0;i<iAdjustSizeToSector;i++)
		{
			write(iFd,&cCh,1);
		}
	}
	else
	{
		printf("[INFO] File size is aligned 512 byte \n");
	}
	//return num of sectors
	iSectorCount = (iSourceSize+iAdjustSizeToSector)/BYTESOFSECTOR;
	return iSectorCount;
}

// inject information for kernel to bootloader
void WriteKernelInformation(int iTargetFd, int iKernelSectorCount)
{
	unsigned short usData;
	long lPosition;
	//reveal inform of num of all sectors 5 bytes away from file starting point
	lPosition = lseek(iTargetFd,5,SEEK_SET);
	if(lPosition==-1)
	{
		fprintf(stderr,"l seek fail Return value = %d, err no = $d,%d\n",lPosition,errno,SEEK_SET);
		exit(-1);
	}
	usData = (unsigned short) iKernelSectorCount;
	write(iTargetFd,&usData,2);
	printf("[INFO] Total sector count except boot loader [%d]\n",iKernelSectorCount);
}

//return the size of target file (Target FD) that is copied for Source File(Source FD)
int CopyFile(int iSourceFd,int iTargetFd)
{
	int iSourceFileSize;
	int iRead;
	int iWrite;
	char vcBuffer[BYTESOFSECTOR];

	iSourceFileSize =0;
	while(1)
	{
		iRead = read(iSourceFd, vcBuffer,sizeof(vcBuffer));
		iWrite = write(iTargetFd,vcBuffer,iRead);

		if(iRead != iWrite)
		{
			fprintf(stderr,"[ERROR] iRead != iWrite..\n");
			exit(-1);
		}
		iSourceFileSize += iRead;
		if(iRead != sizeof(vcBuffer))
		{
			break;
		}
	}
	return iSourceFileSize;
}
