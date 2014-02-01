#include "ThreadedTakePicture.h"
	
ThreadedTakePicture::ThreadedTakePicture( CanonCameraWrapper * wrap_){
	wrap = wrap_;
}

void ThreadedTakePicture::start(){
	startThread(false, false);   // blocking, verbose
}

void ThreadedTakePicture::stop(){
	stopThread();
}
	

void ThreadedTakePicture::threadedFunction(){
					
	EdsError err = 1;

	int count = 0;
	bool took = false;
	while ( err != EDS_ERR_OK ){
		
		err = EdsSendCommand( *wrap->camera(), kEdsCameraCommand_TakePicture, 0);
		
		if(err == EDS_ERR_OK){
			printf("takePictureThreaded ok %l\n", err);
			took = true;
		}else{
			printf("takePictureThreaded KO!!!!! .%u., retry...\n", err);
			ofSleepMillis(250);
			count++;
		}
		
		if (count > 5 ){
			printf("we give up Trying to Take Picture\n");
			took = false;
			break;
			//err = EDS_ERR_OK;
		}
	}
		

	if(took){
		ofSleepMillis(1500);
		wrap->downloadLastImage();
	}
	printf("Ending TakePictueThread\n");
	stopThread();
}
